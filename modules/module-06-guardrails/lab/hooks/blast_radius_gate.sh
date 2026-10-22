#!/usr/bin/env bash
# Pre-apply gate. Blocks a terraform plan based on blast radius, mechanically,
# by reading `terraform show -json` output, not by asking the agent nicely.
#
# Usage: blast_radius_gate.sh <plan.json>
# Exit 0 = pass, safe to apply. Exit 1 = blocked, do not apply.
#
# Policy, overridable via env:
#   MAX_RESOURCES      default 5
#   BLOCK_ON_DELETE     default 1 (true)
#   HIGH_RADIUS_TYPES   default "aws_vpc,aws_iam_policy,aws_iam_role"
set -uo pipefail

PLAN_JSON="${1:?usage: blast_radius_gate.sh <plan.json>}"
MAX_RESOURCES="${MAX_RESOURCES:-5}"
BLOCK_ON_DELETE="${BLOCK_ON_DELETE:-1}"
HIGH_RADIUS_TYPES="${HIGH_RADIUS_TYPES:-aws_vpc,aws_iam_policy,aws_iam_role}"

[ -f "$PLAN_JSON" ] || { echo "GATE ERROR: no such plan file: $PLAN_JSON" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "GATE ERROR: jq not found on PATH." >&2; exit 1; }

# Fail closed. `set -uo pipefail` does not stop this script on a failed command,
# because -e is not enabled, so every jq call is checked here instead. Without
# this, a malformed or wrong-shaped plan makes jq print nothing, the integer
# tests below silently evaluate to false, and the script falls through to
# "gate passes". A plan this gate cannot read is not a zero-risk plan.
count() {
  local out
  out=$(jq "$1" "$PLAN_JSON" 2>/dev/null) || return 1
  case "$out" in ''|*[!0-9]*) return 1 ;; esac
  printf '%s' "$out"
}
unreadable() {
  echo "GATE ERROR: could not read a valid Terraform plan from $PLAN_JSON." >&2
  echo "BLOCKED: parser or tool failure is not a pass. Failing closed." >&2
  exit 1
}

jq -e 'type == "object" and (.resource_changes | type) == "array"' "$PLAN_JSON" >/dev/null 2>&1 || unreadable
TOTAL=$(count '[.resource_changes[] | select(.change.actions != ["no-op"])] | length') || unreadable
DELETES=$(count '[.resource_changes[] | select(.change.actions | index("delete"))] | length') || unreadable

echo "==> gate: ${TOTAL} resource change(s), ${DELETES} delete(s), max allowed ${MAX_RESOURCES}"

if [ "$BLOCK_ON_DELETE" = "1" ] && [ "$DELETES" -gt 0 ]; then
  echo "BLOCKED: ${DELETES} delete action(s) in this plan. block-on-delete is on." >&2
  jq -r '.resource_changes[] | select(.change.actions | index("delete")) | "  - delete: \(.type).\(.name)"' "$PLAN_JSON" >&2
  exit 1
fi

if [ "$TOTAL" -gt "$MAX_RESOURCES" ]; then
  echo "BLOCKED: ${TOTAL} resource changes exceeds the max-resources policy of ${MAX_RESOURCES}." >&2
  exit 1
fi

IFS=',' read -ra TYPES <<< "$HIGH_RADIUS_TYPES"
for t in "${TYPES[@]}"; do
  HIT=$(count "[.resource_changes[] | select(.type == \"$t\") | select(.change.actions != [\"no-op\"])] | length") || unreadable
  if [ "$HIT" -gt 0 ]; then
    echo "BLOCKED: this plan touches ${HIT} resource(s) of high-radius type '${t}'." >&2
    exit 1
  fi
done

echo "    ok, gate passes"
exit 0
