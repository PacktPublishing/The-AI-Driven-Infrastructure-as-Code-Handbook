#!/usr/bin/env bash
# tool-shims.test.sh -- reproduces, on any machine, the Windows failure that tool-shims.sh
# exists for, then asserts the shim closes it. Exits non-zero on any failure.
#
# The failure: on Windows, pip puts a `checkov` launcher script on PATH whose `#!` line
# names a Windows Python path. PowerShell never reads it (it runs checkov.exe), but Git
# Bash does, and cannot execute it:
#
#   checkov: cannot execute: required file not found
#   BLOCKED at checkov
#
# This test fakes that launcher, puts it first on PATH, and runs the Module 9 pipeline
# against the solution module. Stages 1 and 2 must pass, stage 3 must pass through the
# python -m fallback, and the shim must say which command it used.
#
# Needs: terraform, trivy, conftest, python3 with checkov importable
# (`python3 -m checkov.main --version`), and Floci answering on :4566 for stage 4
# (`docker compose -f labs/shared/docker-compose.floci.yml up -d`).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
PIPELINE="$ROOT/modules/module-09-verifying-ai-infra/lab/pipeline.sh"
FAKE="$(mktemp -d)"
OUT="$(mktemp -d)"
fail(){ echo "FAIL: $*" >&2; rm -rf "$FAKE" "$OUT"; exit 1; }

# The launcher pip writes on Windows, minus nothing that matters: bash reads the first
# line, looks for C:/Python312/python.exe, and stops right there.
cat >"$FAKE/checkov" <<'EOF'
#!C:/Python312/python.exe
# -*- coding: utf-8 -*-
import re, sys
from checkov.main import run
sys.exit(run())
EOF
chmod +x "$FAKE/checkov"
REAL_PATH="$PATH"

echo "==> 1. the fake launcher reproduces the reader's failure under bash"
PATH="$FAKE:$PATH" bash -c 'checkov --version' >"$OUT/fake.log" 2>&1 && fail "the fake launcher ran; the reproduction is broken"
grep -Eq "bad interpreter|cannot execute" "$OUT/fake.log" || fail "expected a bad-interpreter error, got: $(cat "$OUT/fake.log")"
echo "    ok: $(tr -d '\n' <"$OUT/fake.log" | sed 's/^.*checkov: //')"

echo "==> 2. checkov_cmd falls back to python -m checkov.main and says so"
[ -f "$HERE/tool-shims.sh" ] || fail "labs/shared/tool-shims.sh is missing"
. "$HERE/tool-shims.sh"
export PATH="$FAKE:$REAL_PATH"
CMD=$(checkov_cmd 2>"$OUT/resolve.err") || fail "checkov_cmd found nothing: $(cat "$OUT/resolve.err")"
case "$CMD" in
  *" -m checkov.main") ;;
  *) fail "expected a 'python -m checkov.main' command, got: $CMD" ;;
esac
grep -q "checkov.main" "$OUT/resolve.err" || fail "the shim did not print which command it resolved: $(cat "$OUT/resolve.err")"
echo "    ok, resolved: $CMD"
echo "    note: $(cat "$OUT/resolve.err")"

echo "==> 3. with the fake launcher first on PATH, M09 pipeline.sh solution passes stage 3"
M09_OUT="$OUT/m09" bash "$PIPELINE" solution >"$OUT/pipeline.log" 2>&1
CODE=$?
grep -q "stage 2/5: trivy" "$OUT/pipeline.log" || fail "stage 2 never ran: $(tail -5 "$OUT/pipeline.log")"
grep -q "BLOCKED at checkov" "$OUT/pipeline.log" && fail "stage 3 still blocked: $(grep -B2 'BLOCKED' "$OUT/pipeline.log")"
grep -q "checkov: no unreviewed findings" "$OUT/pipeline.log" || fail "stage 3 did not pass: $(tail -15 "$OUT/pipeline.log")"
grep -q "checkov.main" "$OUT/pipeline.log" || fail "pipeline did not print the resolved checkov command"
[ "$CODE" -eq 0 ] || fail "pipeline.sh exited $CODE after stage 3 passed: $(tail -10 "$OUT/pipeline.log")"
echo "    ok, exit 0: $(grep 'checkov.main' "$OUT/pipeline.log" | head -1 | sed 's/^ *//')"

echo "==> 4. with a working checkov on PATH, checkov_cmd returns checkov itself, silently"
export PATH="$REAL_PATH"
CMD=$(checkov_cmd 2>"$OUT/resolve2.err") || fail "checkov_cmd found nothing with the real PATH"
[ "$CMD" = "checkov" ] || fail "expected 'checkov', got: $CMD"
[ ! -s "$OUT/resolve2.err" ] || fail "expected no note on the normal path, got: $(cat "$OUT/resolve2.err")"
echo "    ok"

rm -rf "$FAKE" "$OUT"
echo
echo "TOOL-SHIMS PASSED: the Windows launcher failure reproduces, and the shim routes around it"
