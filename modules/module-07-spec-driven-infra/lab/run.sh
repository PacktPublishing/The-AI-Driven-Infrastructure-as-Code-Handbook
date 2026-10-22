set -uo pipefail
cd "$(dirname "$0")"
fail(){ echo "FAIL: $*" >&2; exit 1; }

echo "==> starting Floci (autoscaling, ec2, iam services)"
docker rm -f m07-floci >/dev/null 2>&1
docker run -d --name m07-floci -p 4566:4566 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  floci/floci:1.7.0 >/dev/null || fail "could not start floci"
READY=0
for i in $(seq 1 30); do
  curl -sf http://localhost:4566/_localstack/health >/dev/null 2>&1 && { READY=1; break; }
  sleep 2
done
[ "$READY" = "1" ] || fail "floci never became healthy on :4566"

echo "==> spec-driven: fmt + init + validate"
terraform -chdir=spec-driven fmt -check -diff . >/tmp/m07-fmt.log 2>&1 || fail "spec-driven not fmt-clean: $(cat /tmp/m07-fmt.log)"
terraform -chdir=spec-driven init -backend=false -input=false -no-color >/dev/null || fail "spec-driven init"
terraform -chdir=spec-driven validate -no-color >/tmp/m07-validate.log 2>&1
grep -q "Success" /tmp/m07-validate.log || fail "spec-driven validate: $(cat /tmp/m07-validate.log)"

echo "==> vibe-coded: fmt + init + validate (still valid HCL, that's the point, nothing stops it)"
terraform -chdir=vibe-coded fmt -check -diff . >/tmp/m07-fmt2.log 2>&1 || fail "vibe-coded not fmt-clean: $(cat /tmp/m07-fmt2.log)"
terraform -chdir=vibe-coded init -backend=false -input=false -no-color >/dev/null || fail "vibe-coded init"
terraform -chdir=vibe-coded validate -no-color >/tmp/m07-validate2.log 2>&1
grep -q "Success" /tmp/m07-validate2.log || fail "vibe-coded validate: $(cat /tmp/m07-validate2.log)"

echo "==> the five judgment calls the ticket left silent: plan output must actually diverge"
terraform -chdir=spec-driven plan -no-color -input=false >/tmp/m07-plan-spec.log 2>&1 || fail "spec-driven plan"
terraform -chdir=vibe-coded plan -no-color -input=false >/tmp/m07-plan-vibe.log 2>&1 || fail "vibe-coded plan"
python3 -c "
import re, sys

spec = open('/tmp/m07-plan-spec.log').read()
vibe = open('/tmp/m07-plan-vibe.log').read()

def val(text, key):
    m = re.search(rf'{key}\s*=\s*(.+)', text)
    return m.group(1).strip() if m else None

checks = [
    ('health_check_grace_period', '180', '60'),
    ('min_size', '2', '2'),
    ('max_size', '4', '6'),
    ('target_value', '55', '60'),
]
for key, want_spec, want_vibe in checks:
    got_spec = val(spec, key)
    got_vibe = val(vibe, key)
    if got_spec != want_spec:
        print(f'spec-driven {key}: expected {want_spec}, got {got_spec}'); sys.exit(1)
    if got_vibe != want_vibe:
        print(f'vibe-coded {key}: expected {want_vibe}, got {got_vibe}'); sys.exit(1)

if 'termination_policies' not in spec:
    print('spec-driven should pin termination_policies explicitly'); sys.exit(1)
if 'termination_policies' in vibe:
    print('vibe-coded should leave termination_policies unset (AWS default), the whole point'); sys.exit(1)

if 'http_tokens' not in spec or 'required' not in spec:
    print('spec-driven should require IMDSv2 tokens'); sys.exit(1)
if 'http_tokens' in vibe:
    print('vibe-coded should leave metadata_options unset, IMDSv1 left reachable'); sys.exit(1)
print('    ok, all five judgment calls genuinely diverge between the two runs')
" || fail "plan-diff assertions failed"

# SC-006 is a policy result, so it is read from checkov's own JSON, not searched for in
# text. A text search cannot tell "this check passed" apart from "the scan never ran":
# if checkov crashes, the id is absent either way and the old grep chain silently
# reported success. Exit status 0 means no failures, 1 means findings, anything else is
# a broken scan.
run_checkov() { # run_checkov <dir> <outfile>
  # No --quiet here: it suppresses passed_checks in the JSON, and SC-006 is a claim
  # about a check passing, which cannot be proved from an empty array.
  checkov -d "$1" -o json --compact > "$2" 2>/tmp/m07-checkov-err.log
  local rc=$?
  [ "$rc" -le 1 ] || fail "checkov errored on $1 (exit $rc): $(tail -5 /tmp/m07-checkov-err.log)"
  python3 - "$2" <<'PY' || fail "checkov produced no usable JSON for $1"
import json,sys
d=json.load(open(sys.argv[1]))
d=d[0] if isinstance(d,list) else d
r=d.get("results",{})
assert r.get("passed_checks") is not None or r.get("failed_checks") is not None
PY
}
checkov_has() { # checkov_has <outfile> <passed|failed> <check_id>
  python3 - "$1" "$2" "$3" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
d=d[0] if isinstance(d,list) else d
ids={c["check_id"] for c in d.get("results",{}).get(sys.argv[2]+"_checks") or []}
sys.exit(0 if sys.argv[3] in ids else 1)
PY
}

echo "==> checkov: spec-driven passes the one check it was told to (IMDSv2), still has a real unscoped gap (tags)"
run_checkov spec-driven /tmp/m07-checkov-spec.json
checkov_has /tmp/m07-checkov-spec.json passed CKV_AWS_79 || fail "SC-006: CKV_AWS_79 (IMDSv2) is not in checkov's passed set for spec-driven"
checkov_has /tmp/m07-checkov-spec.json failed CKV_AWS_79 && fail "SC-006: CKV_AWS_79 appears as a failure on spec-driven"
checkov_has /tmp/m07-checkov-spec.json failed CKV_AWS_153 || fail "expected CKV_AWS_153 (tags) to still fail on spec-driven, honestly, the spec never asked for it"
echo "    ok, CKV_AWS_79 explicitly in passed_checks, CKV_AWS_153 explicitly in failed_checks"

echo "==> checkov: vibe-coded fails exactly what FR-005 would have caught, plus real gaps on the unrequested ALB it invented"
run_checkov vibe-coded /tmp/m07-checkov-vibe.json
checkov_has /tmp/m07-checkov-vibe.json failed CKV_AWS_79 || fail "expected CKV_AWS_79 (IMDSv1 left on) to fail on vibe-coded"
checkov_has /tmp/m07-checkov-vibe.json failed CKV_AWS_2 || fail "expected an ALB/TLS finding on the ALB nobody asked for"
echo "    ok"

echo "==> spec.md carries all three real parts: requirements, constraints, success criteria"
grep -q "^### Functional Requirements" spec-driven/spec.md || fail "spec.md missing Functional Requirements"
grep -q "^### Constraints" spec-driven/spec.md || fail "spec.md missing Constraints"
grep -q "^## Success Criteria" spec-driven/spec.md || fail "spec.md missing Success Criteria"
echo "    ok"

echo "==> real apply + destroy of the spec-driven module against Floci, values checked against SC-001..SC-004"
terraform -chdir=spec-driven apply -auto-approve -input=false >/tmp/m07-apply.log 2>&1 || fail "spec-driven apply: $(tail -20 /tmp/m07-apply.log)"
terraform -chdir=spec-driven state show aws_autoscaling_group.checkout_web > /tmp/m07-state.log 2>&1 \
  || fail "could not read applied ASG state: $(tail -5 /tmp/m07-state.log)"
# SC-005 lives on the launch template, not the group, and Floci does not record a
# launch template's metadata_options at all, so applied state cannot prove it here.
# The plan can: it is what Terraform would actually send to the API. Read from the
# plan's own JSON rather than grepping console output, the same way M06's gate does.
terraform -chdir=spec-driven plan -out=sc005.tfplan -input=false -no-color >/dev/null 2>&1 \
  || fail "SC-005: could not produce a plan to inspect"
terraform -chdir=spec-driven show -json sc005.tfplan > /tmp/m07-plan.json 2>/dev/null \
  || fail "SC-005: terraform show -json failed, so there is no plan to inspect"
python3 - /tmp/m07-plan.json <<'PY' || fail "SC-005: IMDSv2 not required in the planned launch template"
import json,sys
d=json.load(open(sys.argv[1]))
lt=[c for c in d.get("resource_changes",[]) if c.get("type")=="aws_launch_template"]
if not lt:
    print("SC-005: no aws_launch_template in the plan"); sys.exit(1)
mo=(lt[0].get("change",{}).get("after") or {}).get("metadata_options") or []
tok=mo[0].get("http_tokens") if mo else None
if tok != "required":
    print(f"SC-005: planned http_tokens expected required, got {tok}"); sys.exit(1)
print("    ok, SC-005 proved from the plan: http_tokens = required")
PY
rm -f spec-driven/sc005.tfplan
python3 -c "
import re, sys
t = open('/tmp/m07-state.log').read()
def val(text, key):
    m = re.search(rf'{key}\s*=\s*(.+)', text)
    return m.group(1).strip() if m else None
want = {'health_check_grace_period': '180', 'min_size': '2', 'max_size': '4', 'default_cooldown': '90'}
for k, w in want.items():
    got = val(t, k)
    if got != w:
        print(f'applied state {k}: expected {w}, got {got}'); sys.exit(1)
if 'OldestLaunchTemplate' not in t:
    print('applied state missing termination_policies'); sys.exit(1)
print('    ok, applied state matches SC-001, SC-002, SC-003 and the cooldown half of SC-004')
" || fail "applied state didn't match spec"
# Floci does not record default_instance_warmup, so the warmup half of SC-004 is asserted
# against the configuration rather than applied state. Stated in spec.md under Scope.
grep -qE '^[[:space:]]*default_instance_warmup[[:space:]]*=[[:space:]]*90[[:space:]]*$' spec-driven/main.tf \
  || fail "SC-004: default_instance_warmup = 90 is not set in spec-driven/main.tf"
terraform -chdir=spec-driven destroy -auto-approve -input=false >/tmp/m07-destroy.log 2>&1 || fail "spec-driven destroy: $(tail -20 /tmp/m07-destroy.log)"
grep -q "Destroy complete" /tmp/m07-destroy.log || fail "destroy didn't complete cleanly"
echo "    ok, applied for real, values matched SC-001 through SC-004, destroyed cleanly"

rm -rf spec-driven/.terraform spec-driven/.terraform.lock.hcl spec-driven/terraform.tfstate*

echo "==> Step 6: OpenTofu apply/destroy, same module"
tofu -chdir=spec-driven init -backend=false -input=false -no-color >/dev/null || fail "spec-driven tofu init"
tofu -chdir=spec-driven apply -auto-approve -input=false >/tmp/m07-tofu-apply.log 2>&1 || fail "tofu apply: $(tail -20 /tmp/m07-tofu-apply.log)"
grep -q "3 added" /tmp/m07-tofu-apply.log || fail "tofu apply: expected the same 3 resources terraform applied"
tofu -chdir=spec-driven destroy -auto-approve -input=false >/tmp/m07-tofu-destroy.log 2>&1 || fail "tofu destroy: $(tail -20 /tmp/m07-tofu-destroy.log)"
grep -q "3 destroyed" /tmp/m07-tofu-destroy.log || fail "tofu destroy didn't complete cleanly"
echo "    ok, OpenTofu applied and destroyed the identical HCL, same resource count as terraform"

rm -rf spec-driven/.terraform spec-driven/.terraform.lock.hcl spec-driven/terraform.tfstate* \
       vibe-coded/.terraform vibe-coded/.terraform.lock.hcl vibe-coded/terraform.tfstate*
docker rm -f m07-floci >/dev/null 2>&1

echo
echo "LAB PASSED, five real judgment calls genuinely diverge between the vibe-coded and"
echo "spec-driven runs, spec-driven applied for real against Floci with every value matching"
echo "its own success criteria, and checkov still found a real gap neither run's spec covered"
