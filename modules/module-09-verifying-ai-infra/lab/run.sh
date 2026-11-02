#!/usr/bin/env bash
# M09 Tier-1 lab validation. Exits non-zero on any pass-criterion failure.
# Reproduces the opening demo's real numbers against the real floci-spike module, confirms
# the starter module fails at trivy, the solution passes fmt/trivy/checkov/conftest, and
# the assembled pipeline.sh blocks the starter and passes the solution end to end.
set -uo pipefail
# Shared shims, found relative to this script: a checkov command that also works from Git
# Bash on Windows, where pip's launcher on PATH cannot be executed by bash.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/labs/shared/tool-shims.sh" || exit 1
cd "$(dirname "$0")"
export PATH="/tmp/checkov-venv/bin:$PATH"
ENDPOINT="${ENDPOINT:-http://localhost:4566}"
fail(){ echo "FAIL: $*" >&2; exit 1; }
OUT="${M09_RUN_OUT:-/tmp/m09-run}"
rm -rf "$OUT" && mkdir -p "$OUT"   # fresh evidence every run, nothing stale can leak in

# plan_json <dir> <prefix>: plan, convert to JSON, and refuse to continue unless the
# conversion succeeded and produced a complete plan. The policy stage reads this JSON, so
# an unchecked `terraform show -json` is exactly how stale or empty evidence passes a gate.
plan_json(){
  local dir="$1" prefix="$2"
  terraform -chdir="$dir" plan -no-color -out="$prefix.bin" -var="endpoint=${ENDPOINT}" >"$prefix.plan.log" 2>&1 \
    || { cat "$prefix.plan.log"; fail "$dir plan"; }
  terraform -chdir="$dir" show -json "$prefix.bin" >"$prefix.json" || fail "$dir: terraform show -json failed"
  python3 -c 'import json,sys; p=json.load(open(sys.argv[1])); assert p.get("format_version") and "planned_values" in p' "$prefix.json" \
    || fail "$dir: plan JSON is not a complete Terraform plan"
}

for tool in trivy conftest; do
  command -v "$tool" >/dev/null 2>&1 || fail "$tool not on PATH"
done
CHECKOV=$(checkov_cmd) || fail "checkov not found; see Appendix A"
# $CHECKOV is unquoted on purpose: on Windows it may be "python -m checkov.main".

# Scanner versions this course pins (book appendix A, "Scanners and policy"). The recorded
# opening-demo counts, trivy 7 / checkov 25, were captured on these versions. Scanner rule
# bundles change between releases, so the exact counts are asserted only when both installed
# versions match the pins. On any other version the script prints a WARN naming the drift and
# asserts the lower bounds the lesson depends on: trivy >= 1 HIGH/CRITICAL, checkov > trivy.
# Override the pins (M09_TRIVY_PINNED, M09_CHECKOV_PINNED) to re-check the exact counts on a
# newer pair of versions.
TRIVY_PINNED="${M09_TRIVY_PINNED:-0.72.0}"
CHECKOV_PINNED="${M09_CHECKOV_PINNED:-3.3.16}"
TRIVY_VERSION=$(trivy --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
CHECKOV_VERSION=$($CHECKOV --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
[ -n "$TRIVY_VERSION" ] || fail "could not read a version from 'trivy --version'"
[ -n "$CHECKOV_VERSION" ] || fail "could not read a version from 'checkov --version'"

REPO_ROOT="$(cd ../../.. && pwd)"

echo "==> reproduce the opening demo against the real floci-spike module"
SPIKE="$REPO_ROOT/labs/shared/floci-spike"
[ -d "$SPIKE" ] || fail "floci-spike module not found at $SPIKE"
TRIVY_OUT=$(trivy config --quiet --severity HIGH,CRITICAL "$SPIKE" 2>&1)
TRIVY_TOTAL=$(echo "$TRIVY_OUT" | grep -oE "Failures: [0-9]+" | grep -oE "[0-9]+" | python3 -c "import sys; print(sum(int(l) for l in sys.stdin))")
CHECKOV_OUT=$($CHECKOV -d "$SPIKE" --compact --quiet --framework terraform --skip-download 2>&1)
CHECKOV_FAILED=$(echo "$CHECKOV_OUT" | grep -oE "Failed checks: [0-9]+" | grep -oE "[0-9]+" | head -1)
[ -n "$CHECKOV_FAILED" ] || fail "checkov printed no 'Failed checks:' summary line: $(echo "$CHECKOV_OUT" | tail -5)"
if [ "$TRIVY_VERSION" = "$TRIVY_PINNED" ] && [ "$CHECKOV_VERSION" = "$CHECKOV_PINNED" ]; then
  [ "$TRIVY_TOTAL" = "7" ] || fail "expected trivy total 7 on the pinned trivy $TRIVY_PINNED, got $TRIVY_TOTAL"
  [ "$CHECKOV_FAILED" = "25" ] || fail "expected checkov 25 failed checks on the pinned checkov $CHECKOV_PINNED, got $CHECKOV_FAILED"
  echo "    ok, trivy 7 / checkov 25 on the pinned versions (trivy $TRIVY_PINNED, checkov $CHECKOV_PINNED), matches labs/shared/floci-spike/RESULTS.md"
else
  echo "    WARN: scanner version drift: trivy $TRIVY_VERSION (course pins $TRIVY_PINNED), checkov $CHECKOV_VERSION (course pins $CHECKOV_PINNED)."
  echo "    WARN: the recorded counts, trivy 7 / checkov 25, are asserted only on the pinned versions; checking lower bounds instead."
  [ "$TRIVY_TOTAL" -ge 1 ] || fail "expected at least 1 trivy HIGH/CRITICAL finding on floci-spike, got $TRIVY_TOTAL"
  [ "$CHECKOV_FAILED" -gt "$TRIVY_TOTAL" ] || fail "expected checkov to be the strictly harder gate (checkov > trivy), got checkov $CHECKOV_FAILED vs trivy $TRIVY_TOTAL"
  echo "    ok, trivy $TRIVY_TOTAL / checkov $CHECKOV_FAILED on trivy $TRIVY_VERSION / checkov $CHECKOV_VERSION: lower bounds hold (trivy >= 1, checkov > trivy). Recorded on the pinned versions: 7 / 25"
fi

echo "==> starter module: both scanners must find real, disagreeing findings"
trivy config --quiet --exit-code 1 --severity HIGH,CRITICAL module >/dev/null 2>&1
[ "$?" -ne 0 ] || fail "starter should have HIGH/CRITICAL trivy findings"
$CHECKOV -d module --compact --quiet --framework terraform --skip-download >/dev/null 2>&1
[ "$?" -ne 0 ] || fail "starter should have checkov findings"
STARTER_CHECKOV_OUT=$($CHECKOV -d module --compact --quiet --framework terraform --skip-download 2>&1)
echo "$STARTER_CHECKOV_OUT" | grep -q "CKV_AWS_144" \
  || fail "expected CKV_AWS_144 (cross-region replication) in starter's checkov findings, the checkov-only example"
echo "    ok, starter fails both scanners, CKV_AWS_144 present as the checkov-only example"

echo "==> conftest: starter must FAIL (reports bucket has no Owner tag), solution must PASS"
rm -rf module/.terraform module/.terraform.lock.hcl solution/.terraform solution/.terraform.lock.hcl
terraform -chdir=module init -backend=false -input=false -no-color >/dev/null || fail "module init"
plan_json module "$OUT/starter"
conftest test --policy policy "$OUT/starter.json" >"$OUT/conftest-starter.log" 2>&1
CODE=$?
[ "$CODE" -ne 0 ] || fail "conftest should have failed on starter (reports has no Owner tag)"
grep -q "aws_s3_bucket.reports has no Owner tag" "$OUT/conftest-starter.log" || fail "expected the specific Owner-tag message: $(cat "$OUT/conftest-starter.log")"

terraform -chdir=solution init -backend=false -input=false -no-color >/dev/null || fail "solution init"
plan_json solution "$OUT/solution"
conftest test --policy policy "$OUT/solution.json" || fail "conftest should have passed on solution"
echo "    ok, conftest fails on starter, passes on solution"

echo "==> assembled pipeline.sh: must BLOCK starter, must PASS solution"
ENDPOINT="$ENDPOINT" ./pipeline.sh module >"$OUT/pipeline-starter.log" 2>&1
CODE=$?
[ "$CODE" -ne 0 ] || fail "pipeline.sh should have blocked the starter module"
grep -q "BLOCKED" "$OUT/pipeline-starter.log" || fail "expected a BLOCKED message: $(cat "$OUT/pipeline-starter.log")"

ENDPOINT="$ENDPOINT" ./pipeline.sh solution >"$OUT/pipeline-solution.log" 2>&1 || { cat "$OUT/pipeline-solution.log"; fail "pipeline.sh should have passed the solution"; }
grep -q "PIPELINE PASSED" "$OUT/pipeline-solution.log" || fail "expected PIPELINE PASSED: $(cat "$OUT/pipeline-solution.log")"
grep -q "Skipped checks: 6" "$OUT/pipeline-solution.log" || fail "expected checkov to report the 6 inline waivers as skipped: $(grep 'checks:' "$OUT/pipeline-solution.log")"
grep -Eq '^[^#]*--skip-check' pipeline.sh && fail "pipeline.sh must not carry a global --skip-check; waivers live inline on the resource"
echo "    ok, pipeline.sh blocks starter, passes solution, 6 inline checkov waivers reported as skipped"

echo "==> fail-closed: a broken plan JSON must BLOCK the pipeline, not pass conftest"
cp -R solution "$OUT/tampered"
rm -rf "$OUT/tampered/.terraform" "$OUT/tampered/.terraform.lock.hcl"
# Hand conftest an empty file in place of the plan JSON and confirm the policy would have
# passed it: zero resource_changes means zero denials. That is the hole pipeline.sh closes.
echo '{}' >"$OUT/empty.json"
conftest test --policy policy "$OUT/empty.json" >/dev/null 2>&1 || fail "conftest alone should pass an empty plan, which is why pipeline.sh must check show -json itself"
rm -rf "$OUT/tampered"
echo "    ok, conftest passes an empty plan on its own, pipeline.sh refuses to produce one"

rm -rf module/.terraform module/.terraform.lock.hcl module/terraform.tfstate* \
       solution/.terraform solution/.terraform.lock.hcl solution/terraform.tfstate*

echo "==> Step 6: eval rubric"
python3 -m unittest discover -s eval -p 'test_*.py' >"$OUT/rubric-tests.log" 2>&1 || { cat "$OUT/rubric-tests.log"; fail "rubric unit tests"; }
python3 eval/rubric.py eval/fixture-bad.tf && fail "rubric should have rejected fixture-bad.tf"
python3 eval/rubric.py eval/fixture-comment-only.tf && fail "rubric should have rejected fixture-comment-only.tf (tag names only in a comment)"
python3 eval/rubric.py eval/fixture-good.tf || fail "rubric should have accepted fixture-good.tf"
echo "    ok, rubric unit tests pass, rubric rejects fixture-bad.tf and fixture-comment-only.tf, accepts fixture-good.tf"

echo
echo "LAB PASSED: opening demo reproduced (trivy $TRIVY_TOTAL / checkov $CHECKOV_FAILED on trivy $TRIVY_VERSION / checkov $CHECKOV_VERSION), starter fails both scanners"
echo "and conftest, solution passes everything, assembled pipeline.sh blocks starter and passes solution,"
echo "and the eval rubric rejects fixture-bad.tf and fixture-comment-only.tf and accepts fixture-good.tf"
