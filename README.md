# The-AI-Driven-Infrastructure-as-Code-Handbook
by Packt Publishing

This is the companion repository for *Agentic Infrastructure as Code: AI Agents for DevOps*.
It carries the runnable version of every command, every config, and every narrated build in
the book: thirteen chapters' worth of labs, specs, policy bundles, reading material and the
capstone.

You do not need it to read the book. Every important piece of output is reproduced in the
text. You want it the moment you decide to run something yourself.

**All thirteen chapters are here.** Twelve modules plus the capstone, complete.

## Where each chapter's material lives

The book cites these paths directly, and they resolve here exactly as printed.

| Chapter | Path |
|---|---|
| 1 | `modules/module-01-clickops-to-agents/` |
| 2 | `modules/module-02-your-workstation/` |
| 3 | `modules/module-03-context-engineering/` |
| 4 | `modules/module-04-agent-skills/` |
| 5 | `modules/module-05-mcp-tool-layer/` |
| 6 | `modules/module-06-guardrails/` |
| 7 | `modules/module-07-spec-driven-infra/` |
| 8 | `modules/module-08-harness-engineering/` |
| 9 | `modules/module-09-verifying-ai-infra/` |
| 10 | `modules/module-10-agentic-kubernetes/` |
| 11 | `modules/module-11-agentic-gitops/` |
| 12 | `modules/module-12-loop-multiagent-economics/` |
| 13 | `capstone/` |

Chapters 3, 4 and 9 also run against `labs/shared/floci-spike/`, the pinned local AWS
emulator every Tier 1 lab uses.

That claim is checked, not asserted. `./tools/check-book-contract.sh` asserts that all 176
commands the book prints appear verbatim in a lab file here, and that every path a chapter
names resolves. It runs in CI on every push, and you can run it yourself.

## Quick start

Install the pinned tools first. Every exact version and install command is in Appendix A.
Then:

```
docker compose -f labs/shared/docker-compose.floci.yml up -d
cd labs/shared/floci-spike && ./run.sh
```

Lab tiers 0, 1 and 2 cost nothing and need no cloud account. Tier 3 is optional, capstone
only, and ends with a numbered `terraform destroy`.

## Layout

```
modules/module-NN-*/
  LAB.md            the chapter's hands-on project, copy-pasteable
  README.md         delivery guide
  QUIZ.md           the chapter's questions, with collapsible answers
  PROJECTS.md       stretch projects, hints not solutions
  lab/              the runnable material: starter, solution, run.sh, policy, hooks
  reading/          concepts.md (the standalone read) and reference.md (the cheat sheet)
  explainer/sim/    the chapter's interactive simulator, a single self-contained HTML file
capstone/           spec.md, rubric.md, AGENTS.md, and all three lab tiers
labs/shared/        the Floci compose file and the pinned 1.7.0 spike
demos/              the agent-preview demo, named by path in Chapter 4 and Appendix B
tools/              the gate that checks this repository against the printed book
```

Chapter *N* maps to `modules/module-NN-*`, with one exception: Chapter 13 is `capstone/`.

Every module's `lab/run.sh` is a real check, not a smoke test. Run it.

## Errata and updates

Tools move faster than print. Where a pinned version in Appendix A has gone stale, the fix
lands here first. The gate above is what keeps the rest of the repository honest against
what the book actually printed.
