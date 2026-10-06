# M01 reference card: From ClickOps to Agents

One side of A4. Pin it above your desk.

## The seven eras

| # | Era | Solved | Left behind |
|---|---|---|---|
| 1 | ClickOps | Nothing yet, this is the baseline | No record, no repeatability |
| 2 | Scripts | Repeatable, documented setup | Not idempotent, breaks on re-run |
| 3 | Configuration management | Safe to re-run (idempotent) | No cross-machine environment view |
| 4 | Declarative IaC | Whole environment as one description | State drift between plan and reality |
| 5 | GitOps | Reviewed, auditable, self-correcting | Review load doesn't scale with change volume |
| 6 | AI-assisted | Faster typing, faster fixes | Human still drives every step |
| 7 | Agentic | Closes the loop end to end | Damage can happen before a human notices |

## The six-step autonomy ladder

| Step | Name | What runs unattended | The gate under it |
|---|---|---|---|
| 1 | Suggest | Nothing, human types | N/A, human is the filter |
| 2 | Draft | Agent writes files | Human reads every line |
| 3 | Propose with plan | Agent writes code + plan | Human reads the plan |
| 4 | Gated apply | Agent + automated checks | Human approves after checks pass |
| 5 | Supervised autonomy | Agent loops across iterations | Human reviews outcomes |
| 6 | Unattended | Agent runs to a stopping condition | Human reviews exceptions only |

No step is safe without the gate listed beside it.

## The three layers

| Layer | Contains | Symptom that points here |
|---|---|---|
| Loop | What re-triggers the agent, when it stops | "Works, but I babysit every run" |
| Harness | Skills, tools, MCP, hooks, sandbox, gates | "Works, but ignores our standards" |
| Context | AGENTS.md, repo layout, policy text, retrieval | "Can't get one task right at all" |

Build bottom-up. Never add a loop on top of a broken harness.

## The thesis

**The agent proposes. The pipeline decides.**

The agent's authority ends at the plan. A pipeline of scanners, policy checks, cost
checks, and a human approval step decides whether the plan applies, not the agent's own
confidence in it.

## Why infrastructure is harder than application code

1. **No undo.** Some mistakes have no restore button.
2. **State.** A stale state file makes a wrong plan look exactly as confident as a
   correct one.
3. **Blast radius.** A shared-network bug can take down everything that depends on it at
   once.
4. **Silent failure.** An agent can report success while leaving broken invariants or
   uncleaned state behind. No test suite catches this by default.

## The numbers, with their caveats

- **46%** run AI for infra in production or advanced pilots · **34%** would trust
  autonomous production changes · **43%** name absent guardrails as the top blocker.
  *Firefly State of IaC 2026, a vendor survey.*
- AI-generated infra code: roughly **3 to 4x** the vulnerability density of human-written
  code at matched resource counts, worst at **~4.9x** on single-resource templates,
  falling to **~1.4x** at 20+ resources. *Shaw, arXiv:2608.28021, Aug 2026, single author.*
