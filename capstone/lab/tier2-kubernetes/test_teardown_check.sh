#!/usr/bin/env bash
# Tests the teardown proof in run.sh without a cluster.
#
# run.sh ends by asking Docker whether any container from the kind cluster
# survived `kind delete cluster`. Three things can happen there, and the run
# must only print its success line for the first one:
#   1. Docker answers, and the answer is empty      -> teardown confirmed
#   2. Docker answers, and names a container         -> orphan, fail the run
#   3. Docker cannot answer at all                   -> unconfirmed, fail the run
#
# A stub `docker` on PATH plays each case. run.sh is sourced for its functions
# only (it returns before its first numbered step when sourced), so nothing
# here touches a real cluster or a real Docker daemon.
#
# Usage: bash test_teardown_check.sh      exit 0 = all three cases behave
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
STUB="$(mktemp -d)"
trap 'rm -rf "$STUB"' EXIT

cat >"$STUB/docker" <<'EOF'
#!/usr/bin/env bash
case "${STUB_DOCKER_MODE:?}" in
  none)   exit 0 ;;
  orphan) echo "cap-lab-control-plane"; exit 0 ;;
  error)  echo "Cannot connect to the Docker daemon at unix:///var/run/docker.sock" >&2; exit 1 ;;
esac
EOF
printf '#!/usr/bin/env bash\nexit 0\n' >"$STUB/kind"
chmod +x "$STUB/docker" "$STUB/kind"

# Sourcing run.sh only works if run.sh stops itself when sourced. Check that
# textually first, so an older run.sh is never executed by accident here.
grep -q 'BASH_SOURCE\[0\]' "$HERE/run.sh" && grep -q '^assert_no_orphans()' "$HERE/run.sh" \
  || { echo "FAIL: run.sh does not define assert_no_orphans behind a source guard; refusing to source it" >&2; exit 1; }

PASS=0; FAILED=0
run_case(){ # <label> <stub mode> <expected exit> <expected output substring>
  local label="$1" mode="$2" want_rc="$3" want="$4" out rc
  out=$(cd "$HERE" && STUB_DOCKER_MODE="$mode" STUB="$STUB" PATH="$STUB:$PATH" bash -c '
    source ./run.sh
    export PATH="$STUB:$PATH"   # win over any PATH run.sh set for itself
    assert_no_orphans
    echo "SUCCESS LINE WOULD PRINT"' 2>&1); rc=$?
  if [ "$rc" = "$want_rc" ] && [[ "$out" == *"$want"* ]]; then
    echo "ok   $label (exit $rc): ${out:-<no output>}"; PASS=$((PASS+1))
  else
    echo "FAIL $label: wanted exit $want_rc containing '$want', got exit $rc:"; echo "$out" | sed 's/^/       /'; FAILED=$((FAILED+1))
  fi
}

run_case "no orphan: docker answers, answer empty"        none   0 "SUCCESS LINE WOULD PRINT"
run_case "orphan: docker answers, names a container"       orphan 1 "FAIL: orphan cluster container remains: cap-lab-control-plane"
run_case "docker error: inspection fails, run must stop"   error  1 "FAIL: docker inspection failed, teardown unconfirmed"

echo
echo "$PASS passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
