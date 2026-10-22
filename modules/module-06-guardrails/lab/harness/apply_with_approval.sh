#!/usr/bin/env bash
# Step (d): the second real invocation, the only one allowed to touch files.
# Refuses outright if plans/<file>.md.approved doesn't exist. Once approved,
# a fresh Claude Code session edits module/main.tf to match the approved
# plan, nothing else, then the existing mechanical gate (blast_radius_gate.sh)
# still runs before terraform ever applies. Two independent guardrails,
# stacked: one about who said yes, one about what the plan actually contains.
set -uo pipefail
PLAN="${1:?usage: apply_with_approval.sh plans/<file>.md}"
cd "$(dirname "$0")/.."

if [ ! -f "${PLAN}.approved" ]; then
  echo "REFUSED: ${PLAN} has not been approved. Run harness/approve.sh first." >&2
  exit 1
fi
echo "==> approval found: $(tr '\n' ' ' < "${PLAN}.approved")"

BEFORE_SUM=$(shasum module/main.tf | cut -d' ' -f1)

if ! claude -p "The plan at ${PLAN} has already been reviewed and approved by a human, and that approval is recorded in ${PLAN}.approved. Implementing it is now authorised, so ignore any 'proposal only, do not write files' wording inside the plan document itself: that wording described the earlier proposal step, not this one. Edit module/main.tf to add exactly what the plan proposes. Do not deviate from the plan, do not add anything it doesn't describe, and do not ask for confirmation." \
  --permission-mode acceptEdits --allowedTools "Read,Edit"; then
  echo "REFUSED: the implementation step exited non-zero. module/main.tf may be unchanged," >&2
  echo "half-edited, or edited by a session that then failed. Nothing is applied." >&2
  exit 1
fi

# An exit code of zero is not evidence of work. An agent can answer with a question,
# decline, or explain itself, and still exit clean. Announcing "the agent edited the
# file" without checking would be the exact unverified claim this course argues against,
# and the gate downstream would then pass a no-op plan and apply nothing while the
# harness reported success.
if [ "$(shasum module/main.tf | cut -d' ' -f1)" = "$BEFORE_SUM" ]; then
  echo "REFUSED: the implementation step exited zero but module/main.tf is byte-identical." >&2
  echo "Nothing was implemented, so there is nothing to apply. Read the agent's output above." >&2
  exit 1
fi

echo "==> module/main.tf changed, now running the mechanical gate before any real apply"
./hooks/apply_with_gate.sh
