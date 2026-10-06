# M06 Projects: Guardrails: Permissions, Hooks, Blast Radius

4 stretch projects. Hints, not solutions.

---

### 1. Write a gate for your own team's scariest action

Every team has one change they treat as scary: a production database delete, an IAM policy
change, a load balancer swap. Write a hook, built the same way as this module's
`blast_radius_gate.sh`, that specifically catches it.

**Hint:** start from `resource_changes[].type` and `resource_changes[].change.actions`, same as
this lab. You don't need to handle every possible Terraform resource, just the one that matters.

---

### 2. Break your own gate

Try to construct a `terraform plan` that slips past your own hook, real infrastructure or a hand-
edited plan JSON either way. What did the gate miss? Was it a type it didn't know about, an
action it didn't check for, or a threshold set too loose?

**Hint:** the three checks in this module's gate are additive, not exhaustive. A plan that
`replace`s a resource instead of `delete`-then-`create` might slip past a check written only for
the literal string `"delete"`.

---

### 3. Extend the harness with an expiring approval

Right now `plans/<slug>.md.approved` is valid forever once it exists. Add a timestamp check to
`harness/apply_with_approval.sh` that refuses an approval older than, say, 15 minutes, and makes
the approver re-run `harness/approve.sh`. What's the right expiry window for your own team, and
why: too short and every approval turns into a race against the clock, too long and an approval
granted for one plan quietly covers a plan that drifted after review.

---

### 4. Audit a warning-only check in your own CI

Find one check in your team's real pipeline that prints a warning but doesn't block. Would making
it a real gate, exit non-zero, caller stops, break anything that currently depends on it staying
soft? If so, what would you need to fix first before it's safe to tighten?

**Hint:** a lot of "soft" checks stay soft because turning them into a hard gate would immediately
block work in flight. That's real information about how much technical debt the check has been
quietly absorbing.
