# M06 Reference Card: Guardrails: Permissions, Hooks, Blast Radius

## The gate's contract

```
exit 0   ->  pass, safe to apply
exit 1   ->  blocked, do not apply
```

Both halves have to hold: the script exits non-zero on failure, and the caller (a wrapper
script, a CI step, a pre-commit hook) actually stops when it sees that exit code. A check that
only prints a warning is not a gate.

## Blast radius, mechanical checklist

- [ ] Does the plan contain any `delete` action? (block-on-delete policy)
- [ ] Does the total resource-change count exceed the team's threshold? (max-resources policy)
- [ ] Does the plan touch a resource type on the high-radius list (`aws_vpc`, `aws_iam_role`,
      `aws_iam_policy`, or your own)? (high-radius-types policy)

All three read directly from `terraform show -json`. None require understanding what any
specific resource is for.

## Context vs skill vs hook vs permission boundary

| Layer | Loads | Who decides | Can it block an action? |
|---|---|---|---|
| Context (M03) | Every run | Always on | No, it only informs |
| Skill (M04) | On demand, if matched | The agent, voluntarily | No, only suggests |
| Permission boundary (this module) | Before the run starts | The system | Yes, denies before a plan even exists |
| Hook / gate (this module) | Every attempted `apply` | The system, not the agent | Yes, blocks a specific plan |

## Three kinds of guardrail, side by side

| Kind | How it stops the action | Built where |
|---|---|---|
| Mechanical | Reads `terraform plan -json`, exits non-zero on a bad plan | This module's `hooks/blast_radius_gate.sh` |
| Structural | Removes `apply` access from the agent entirely, PR + GitOps applies | Previewed here, real build in M11 |
| Procedural | Explicit human approval marker required between two separate agent runs | This module's `harness/` scripts |

## The harness's contract

```
harness/propose.sh "<ask>"                    -> real plan, saved to plans/<slug>.md
harness/apply_with_approval.sh plans/<slug>.md -> REFUSED, no .approved marker exists
harness/approve.sh plans/<slug>.md             -> writes plans/<slug>.md.approved
harness/apply_with_approval.sh plans/<slug>.md -> applies, still runs the mechanical gate
```

No marker file, no apply, regardless of how safe the plan looks. Two independent guardrails stack
on the same apply: who approved it, and what the plan actually contains.

## This module's lab, in one line

The exact same delete of a real object: with no gate, it's destroyed for good. With the gate wired
in, it's refused, real non-zero exit, bucket and object still there. A safe additive change passes
the same gate without changing a single policy setting. A separate, explicit approval marker gates
the harness on top of that, independently.
