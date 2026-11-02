#!/usr/bin/env bash
# run.sh -- validates Project 08 end to end, for real.
#
#   ./run.sh                 starter RED, solution GREEN, checkov, real Floci apply, drift check,
#                            state read-back, destroy
#   M08_LIVE_AGENT=1 ./run.sh   also runs the Claude Code probe and asserts the bootstrap answered
#
# Requires terraform (1.6+ for `terraform test`), checkov, and Docker reachable at
# /var/run/docker.sock. Floci is started from labs/shared/docker-compose.floci.yml if it is
# not already answering on :4566.
set -uo pipefail
# Shared shims, found relative to this script: a checkov command that also works from Git
# Bash on Windows, where pip's launcher on PATH cannot be executed by bash.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/labs/shared/tool-shims.sh" || exit 1
cd "$(dirname "$0")"
fail(){ echo "FAIL: $*" >&2; exit 1; }
CHECKOV=$(checkov_cmd) || fail "checkov not found; see Appendix A"
ROOT="$(cd ../../.. && pwd)"
W=/tmp/m08-run; rm -rf "$W"; mkdir -p "$W"

echo "==> starter: the tests written in Stage 3 must be RED against the bare table, each for its own reason"
cp -R orders "$W/starter"; mkdir -p "$W/starter/tests"; cp solution/tests/*.tftest.hcl "$W/starter/tests/"
(cd "$W/starter" && terraform init -backend=false -input=false -no-color >/dev/null 2>&1) || fail "starter init"
for f in "$W"/starter/tests/*.tftest.hcl; do
  name=$(basename "$f" .tftest.hcl)
  (cd "$W/starter" && terraform test -no-color -filter="tests/$name.tftest.hcl") >"$W/starter-test-$name.log" 2>&1
  CODE=$?
  [ "$CODE" -ne 0 ] || fail "tests/$name should be RED before the fix"
  grep -q "Reference to undeclared resource" "$W/starter-test-$name.log" && fail "tests/$name: RED must not be an undeclared-resource error"
done
# Every RED must be a real assertion that evaluated to false, printing the test's own
# error_message. The starter writes point_in_time_recovery and server_side_encryption out as
# enabled = false on purpose: were either block absent, the attribute would be computed and
# plan mode would report "Unknown condition value", which is an error, not RED.
for name in pitr sse policy; do
  grep -q "Unknown condition value" "$W/starter-test-$name.log" && fail "tests/$name: RED must be a false assertion, not an unknown value"
  grep -q "could not be evaluated" "$W/starter-test-$name.log" && fail "tests/$name: RED must be a false assertion, not an unevaluated condition"
  grep -q "Error: Test assertion failed" "$W/starter-test-$name.log" || fail "tests/$name: expected 'Error: Test assertion failed'"
done
grep -q "point-in-time recovery is not enabled on aws_dynamodb_table.orders" "$W/starter-test-pitr.log" || fail "pitr RED must print the test's error_message"
grep -q "Failure! 1 passed, 1 failed." "$W/starter-test-pitr.log" || fail "pitr RED must keep table_shape_unchanged passing"
grep -q "server-side encryption is not enabled on aws_dynamodb_table.orders" "$W/starter-test-sse.log" || fail "sse RED must print the test's error_message"
grep -q "policy actions must not contain a wildcard" "$W/starter-test-policy.log" || fail "policy RED must print the test's error_message"
echo "    ok, red for the right reasons"

echo "==> solution: the same tests must be GREEN"
cp -R solution "$W/solution"; rm -rf "$W/solution/docs"
(cd "$W/solution" && terraform init -backend=false -input=false -no-color >/dev/null 2>&1) || fail "solution init"
(cd "$W/solution" && terraform validate -no-color) >"$W/solution-validate.log" 2>&1 || fail "solution validate"
(cd "$W/solution" && terraform test -no-color) >"$W/solution-test.log" 2>&1 || fail "solution tests should be GREEN"
grep -q "Success!" "$W/solution-test.log" || fail "expected a Success! line from terraform test"
echo "    ok, green"

echo "==> solution: checkov must have scanned the table, passed CKV_AWS_28, and failed nothing but the one accepted finding"
# Checkov exits 1 whenever any check fails, and one accepted finding (CKV_AWS_119, customer-managed
# KMS key) remains on purpose, so the exit status alone cannot be the gate. Read the JSON report
# instead and insist that the scan ran, that it examined the orders table, that CKV_AWS_28 (the
# point-in-time-recovery check the tests cover) PASSED, and that no check other than CKV_AWS_119
# FAILED on any resource. Any other failure, on any resource, stops the runner here.
# $CHECKOV is unquoted on purpose: on Windows it may be "python -m checkov.main".
$CHECKOV -d "$W/solution" --framework terraform -o json >"$W/solution-checkov.json" 2>"$W/solution-checkov.err"
CODE=$?
[ "$CODE" -le 1 ] || { cat "$W/solution-checkov.err"; fail "checkov did not run cleanly (exit $CODE)"; }
python3 - "$W/solution-checkov.json" <<'PY' || fail "checkov report has an unexpected failure or is missing the expected pass"
import json, sys
ACCEPTED = {"CKV_AWS_119"}  # customer-managed CMK: declined by the design, listed honestly in LAB.md
report = json.load(open(sys.argv[1]))
reports = report if isinstance(report, list) else [report]
passed = {(c["check_id"], c["resource"]) for r in reports for c in r.get("results", {}).get("passed_checks", [])}
failed = {(c["check_id"], c["resource"]) for r in reports for c in r.get("results", {}).get("failed_checks", [])}
table = "aws_dynamodb_table.orders"
assert passed or failed, "checkov reported no checks at all"
assert any(res == table for _, res in passed | failed), f"checkov never examined {table}"
assert ("CKV_AWS_28", table) in passed, "CKV_AWS_28 (point-in-time recovery) not in passed_checks"
unexpected = sorted(f"{check} on {res}" for check, res in failed if check not in ACCEPTED)
assert not unexpected, "unexpected FAILED checks: " + ", ".join(unexpected)
assert ("CKV_AWS_119", table) in failed, "CKV_AWS_119 no longer fails; the accepted finding changed, so LAB.md and the design doc are out of date"
accepted = ", ".join(sorted(f"{check} on {res}" for check, res in failed))
print(f"    checkov examined {table}: {len(passed)} passed, {len(failed)} failed")
print(f"    CKV_AWS_28 PASSED; failed checks: {accepted} (accepted); no unexpected failures")
PY
echo "    ok. The remaining finding (CKV_AWS_119, customer-managed key) is accepted and listed honestly in LAB.md"

echo "==> floci: real apply of the solution"
if ! curl -fsS http://localhost:4566/_floci/health >/dev/null 2>&1; then
  docker compose -f "$ROOT/labs/shared/docker-compose.floci.yml" up -d >/dev/null 2>&1 || fail "could not start floci"
  for i in $(seq 1 24); do curl -fsS http://localhost:4566/_floci/health >/dev/null 2>&1 && break; sleep 5; done
  curl -fsS http://localhost:4566/_floci/health >/dev/null 2>&1 || fail "floci did not become healthy"
fi
(cd "$W/solution" && terraform init -input=false -no-color >/dev/null 2>&1) || fail "solution init for apply"
(cd "$W/solution" && terraform apply -auto-approve -input=false -no-color) >"$W/apply.log" 2>&1 || { tail -20 "$W/apply.log"; fail "apply"; }
grep -q "Apply complete! Resources: 2 added" "$W/apply.log" || fail "expected 2 resources added"
echo "    ok, applied against floci"

# From here on the table exists in Floci, so a failed check tears it down before it stops the
# runner. Otherwise the next run would find the table already there.
applied_fail(){
  (cd "$W/solution" && terraform destroy -auto-approve -input=false -no-color) >"$W/destroy-on-fail.log" 2>&1
  fail "$*"
}

echo "==> floci: no drift between apply and destroy, and both flags read back as enabled"
# The plan's own Review Focus: Floci could accept the two flags at apply and silently drop
# them. A plan with no changes right after the apply is the evidence that it did not, and the
# state read-back is the evidence that the flags landed as enabled = true, not merely as
# "no diff". Checked: point_in_time_recovery[0].enabled, server_side_encryption[0].enabled and
# deletion_protection_enabled, from terraform show -json. Floci 1.7.0 also records
# recovery_period_in_days and an AWS-managed kms_key_arn; neither is asserted on, because the
# configuration does not set them.
(cd "$W/solution" && terraform plan -detailed-exitcode -input=false -no-color) >"$W/drift.log" 2>&1
CODE=$?
case "$CODE" in
  0) ;;
  2) tail -30 "$W/drift.log"; applied_fail "plan after apply reports changes (exit 2): floci did not persist the configuration" ;;
  *) tail -30 "$W/drift.log"; applied_fail "plan after apply errored (exit $CODE)" ;;
esac
grep -q "No changes. Your infrastructure matches the configuration." "$W/drift.log" || applied_fail "expected 'No changes.' from the plan after apply"
echo "    drift check: terraform plan -detailed-exitcode exit 0, No changes."
(cd "$W/solution" && terraform state show -no-color aws_dynamodb_table.orders) >"$W/state-show.log" 2>&1 || applied_fail "terraform state show aws_dynamodb_table.orders"
(cd "$W/solution" && terraform show -json) >"$W/state.json" 2>"$W/state.err" || applied_fail "terraform show -json"
python3 - "$W/state.json" <<'PY' || applied_fail "state read-back did not show both flags enabled"
import json, sys
state = json.load(open(sys.argv[1]))
resources = state.get("values", {}).get("root_module", {}).get("resources", [])
table = [r for r in resources if r.get("address") == "aws_dynamodb_table.orders"]
assert table, "aws_dynamodb_table.orders is not in the state"
v = table[0]["values"]
pitr = v.get("point_in_time_recovery") or []
sse = v.get("server_side_encryption") or []
assert pitr and pitr[0].get("enabled") is True, f"point_in_time_recovery read back as {pitr!r}, expected enabled = true"
assert sse and sse[0].get("enabled") is True, f"server_side_encryption read back as {sse!r}, expected enabled = true"
assert v.get("deletion_protection_enabled") is False, f"deletion_protection_enabled read back as {v.get('deletion_protection_enabled')!r}, expected false"
print("    state read-back: point_in_time_recovery.enabled = true, server_side_encryption.enabled = true, deletion_protection_enabled = false")
PY
[ "$(grep -cE "^[[:space:]]+enabled[[:space:]]+= true" "$W/state-show.log")" -eq 2 ] || applied_fail "terraform state show did not print two 'enabled = true' lines"
echo "    ok, no drift and both flags persisted"

echo "==> floci: real destroy of the solution"
(cd "$W/solution" && terraform destroy -auto-approve -input=false -no-color) >"$W/destroy.log" 2>&1 || fail "destroy"
grep -q "Destroy complete! Resources: 2 destroyed" "$W/destroy.log" || fail "expected 2 resources destroyed"
echo "    ok, destroyed against floci"

if [ "${M08_LIVE_AGENT:-0}" = "1" ]; then
  echo "==> live agent: the Superpowers bootstrap must answer in Claude Code"
  command -v claude >/dev/null || fail "claude not on PATH"
  claude -p "Do you have superpowers? Answer in one line: yes or no, then list the exact names of the superpowers skills you can invoke, comma separated. Do not invoke any skill." --max-turns 1 >"$W/probe.log" 2>&1
  grep -qi "^yes" "$W/probe.log" || { cat "$W/probe.log"; fail "bootstrap did not answer yes; is superpowers@claude-plugins-official installed and enabled?"; }
  grep -q "verification-before-completion" "$W/probe.log" || fail "probe did not list the skills"
  echo "    ok, bootstrap loaded"
fi

echo "ALL OK"
