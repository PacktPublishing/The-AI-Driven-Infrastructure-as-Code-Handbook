#!/usr/bin/env bash
# Wraps `terraform apply` with the blast-radius gate. This is the enforced half:
# the gate runs every time, whether or not anything asked for it.
set -uo pipefail
cd "$(dirname "$0")/../module"

terraform plan -no-color -input=false -out=tfplan.bin >/tmp/m06-plan.log 2>&1 || { cat /tmp/m06-plan.log; exit 1; }
if ! terraform show -json tfplan.bin > tfplan.json; then
  echo "apply refused: terraform show -json failed, so there is no plan to gate." >&2
  rm -f tfplan.bin tfplan.json
  exit 1
fi

if ! ../hooks/blast_radius_gate.sh tfplan.json; then
  echo "apply refused: gate blocked this plan." >&2
  rm -f tfplan.bin tfplan.json
  exit 1
fi

# Capture apply's exit status before cleaning up. Without this, a failed apply is masked
# by the rm -f that follows it, and the wrapper reports success to whatever called it.
terraform apply -no-color -input=false -auto-approve tfplan.bin
APPLY_RC=$?
rm -f tfplan.bin tfplan.json
if [ "$APPLY_RC" -ne 0 ]; then
  echo "apply failed: terraform apply exited ${APPLY_RC}. The plan files were removed; fix the cause and re-run." >&2
fi
exit "$APPLY_RC"
