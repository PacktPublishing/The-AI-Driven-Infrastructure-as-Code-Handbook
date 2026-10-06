set -uo pipefail
cd "$(dirname "$0")"
fail(){ echo "FAIL: $*" >&2; exit 1; }

echo "==> pinned-tool prerequisites reachable"
terraform version >/dev/null 2>&1 || fail "terraform not on PATH"
checkov --version >/dev/null 2>&1 || fail "checkov not on PATH"
docker info >/dev/null 2>&1 || fail "docker not reachable"
echo "    ok"

echo "==> step1-suggested: fmt + init + validate (fixed version, path.module bug removed)"
terraform -chdir=solution/step1-suggested fmt -check -diff >/tmp/m02-fmt1.log 2>&1 || fail "step1 not fmt-clean: $(cat /tmp/m02-fmt1.log)"
terraform -chdir=solution/step1-suggested init -backend=false -input=false -no-color >/dev/null || fail "step1 init"
terraform -chdir=solution/step1-suggested validate -no-color >/tmp/m02-validate1.log 2>&1
grep -q "Success" /tmp/m02-validate1.log || fail "step1 validate: $(cat /tmp/m02-validate1.log)"
echo "    ok"

echo "==> step2-drafted: fmt + init + validate"
terraform -chdir=solution/step2-drafted fmt -check -diff >/tmp/m02-fmt2.log 2>&1 || fail "step2 not fmt-clean: $(cat /tmp/m02-fmt2.log)"
terraform -chdir=solution/step2-drafted init -backend=false -input=false -no-color >/dev/null || fail "step2 init"
terraform -chdir=solution/step2-drafted validate -no-color >/tmp/m02-validate2.log 2>&1
grep -q "Success" /tmp/m02-validate2.log || fail "step2 validate: $(cat /tmp/m02-validate2.log)"
echo "    ok"

echo "==> step3-acceptedits: fmt + init + validate"
terraform -chdir=solution/step3-acceptedits fmt -check -diff >/tmp/m02-fmt3.log 2>&1 || fail "step3 not fmt-clean: $(cat /tmp/m02-fmt3.log)"
terraform -chdir=solution/step3-acceptedits init -backend=false -input=false -no-color >/dev/null || fail "step3 init"
terraform -chdir=solution/step3-acceptedits validate -no-color >/tmp/m02-validate3.log 2>&1
grep -q "Success" /tmp/m02-validate3.log || fail "step3 validate: $(cat /tmp/m02-validate3.log)"
echo "    ok"

echo "==> all three must plan clean (validate alone missed a real bug this module found: relative host_path)"
terraform -chdir=solution/step1-suggested plan -no-color >/tmp/m02-plan1.log 2>&1 || fail "step1 plan: $(cat /tmp/m02-plan1.log)"
terraform -chdir=solution/step2-drafted plan -no-color >/tmp/m02-plan2.log 2>&1 || fail "step2 plan: $(cat /tmp/m02-plan2.log)"
terraform -chdir=solution/step3-acceptedits plan -no-color >/tmp/m02-plan3.log 2>&1 || fail "step3 plan: $(cat /tmp/m02-plan3.log)"
echo "    ok"

echo "==> every local_file/host_path reference must wrap path.module in abspath() (the real bug this module found)"
for f in solution/step1-suggested/main.tf solution/step2-drafted/main.tf solution/step3-acceptedits/main.tf; do
  grep -q 'abspath(' "$f" || fail "$f has no abspath() call, the relative-path bug this lab teaches would resurface"
done
echo "    ok"

echo "==> all three must be checkov-clean (no built-in coverage for these resource types, same gap as M01)"
checkov -d solution/step1-suggested --compact --quiet >/tmp/m02-ck1.log 2>&1 || fail "step1 checkov: $(cat /tmp/m02-ck1.log)"
checkov -d solution/step2-drafted --compact --quiet >/tmp/m02-ck2.log 2>&1 || fail "step2 checkov: $(cat /tmp/m02-ck2.log)"
checkov -d solution/step3-acceptedits --compact --quiet >/tmp/m02-ck3.log 2>&1 || fail "step3 checkov: $(cat /tmp/m02-ck3.log)"
echo "    ok"

echo "==> the two draft files must genuinely differ (real finding: same intent, same model, two runs diverge)"
DIFF_LINES=$(diff solution/step1-suggested/main.tf solution/step2-drafted/main.tf | wc -l | tr -d ' ')
[ "$DIFF_LINES" -gt 0 ] || fail "step1 and step2 are identical, the lab's core finding no longer holds"
echo "    ok, $DIFF_LINES diff lines"

echo "==> the custom slash command must exist and be well-formed"
[ -f solution/step3-acceptedits/.claude/commands/tf-check.md ] || fail "tf-check.md slash command missing"
grep -q "^description:" solution/step3-acceptedits/.claude/commands/tf-check.md || fail "tf-check.md missing frontmatter description"
echo "    ok"

rm -rf solution/step1-suggested/.terraform solution/step1-suggested/.terraform.lock.hcl
rm -rf solution/step2-drafted/.terraform solution/step2-drafted/.terraform.lock.hcl
rm -rf solution/step3-acceptedits/.terraform solution/step3-acceptedits/.terraform.lock.hcl

echo
echo "LAB PASSED — step1/2/3 all plan clean, pass checkov, carry the real abspath fix, and genuinely differ from each other"
