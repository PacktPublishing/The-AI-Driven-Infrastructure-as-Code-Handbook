# M12 Reference Card: Loop Engineering, Multi-Agent Ops, Economics

## A loop needs both

| Piece | What it is | Bad example | Good example |
|---|---|---|---|
| Trigger | What re-invokes the agent | "whenever it seems right" | a `schedule:` cron, an event, a webhook, a file change |
| Stopping condition | The exact rule for when it quits | "looks good" | `terraform plan` shows zero changes AND `checkov` exits 0 |

## The six-step ladder, closed

| Step | Name | Gate |
|---|---|---|
| 1 | Suggest | nothing to approve yet |
| 2 | Draft | human reads every line |
| 3 | Propose with plan | human reads the plan |
| 4 | Gated apply | automated checks + human approval |
| 5 | Supervised autonomy | human reviews outcomes |
| 6 | Unattended | human reviews exceptions, only after a complete harness is in place |

## Multi-agent, two shapes

- **Parallel**: independent agents, independent pieces, nobody waits
- **Sequential**: one agent's output feeds the next
- **Claude Code teams**: the real, usable tool this course points to
- **Hermes**: named once, not taught here, a reference point for later

## The economics finding, exact

| | Advertised | Measured |
|---|---|---|
| Caveman | 60-90% token savings | ~8.5% |
| rtk | 60-90% token savings | measured cost **increase** at low reasoning effort |

Ask for the paired measurement. Don't standardize on the marketing page.
