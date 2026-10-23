# M08 Reference Card: Harness Engineering

## Three things called a harness

| Sense | Example | Module |
|---|---|---|
| Runtime harness | Claude Code, Codex, Cursor: the program that runs the model and gives it tools | M02 |
| HARNESS layer | Skills, tools, MCP, hooks, sandbox, gates around the agent | M04 to M06 |
| Workflow harness | A skills library plus a bootstrap that makes the agent follow a process every session | **M08** |

## Install Superpowers

| Runtime | Commands |
|---|---|
| Claude Code | `claude plugin marketplace add anthropics/claude-plugins-official` then `claude plugin install superpowers@claude-plugins-official` then `claude plugin list` |
| Codex | `codex plugin marketplace add anthropics/claude-plugins-official` then `codex plugin add superpowers@claude-plugins-official` then `codex plugin list` |
| Either | Probe: "Do you have superpowers? List the skills you can invoke." A loaded bootstrap answers yes and lists fifteen |

Pin the version shown on screen in the module README. Both runtimes also carry Superpowers in
a built-in directory (a bare `claude plugin install superpowers`, or Codex's `/plugins`
screen); on the day of capture those were an older release. The route above gives both
runtimes the same one.

## The three files that make it work

| File, under the plugin root | Job |
|---|---|
| `hooks/hooks.json` | Registers a `SessionStart` hook matching `startup\|clear\|compact` |
| `hooks/session-start` | Reads `using-superpowers/SKILL.md`, prints it as JSON in the field the runtime reads, inside `<EXTREMELY_IMPORTANT>` |
| `skills/using-superpowers/SKILL.md` | The bootstrap text: check for a skill before any action; where the per-runtime tool mapping lives |

Codex: native skill discovery, no session-start hook, `hooks` declared empty on purpose.

## The basic workflow, in order

1. `brainstorming`: ask before building; small change in chat, project gets a design doc
2. `using-git-worktrees`: isolated workspace after design approval
3. `writing-plans`: tasks with exact paths, the test for each, the verification step
4. `subagent-driven-development` or `executing-plans`: fresh subagent per task, or inline
5. `test-driven-development`: RED, GREEN, REFACTOR; code before test gets deleted
6. `requesting-code-review`: against the plan, by severity
7. `finishing-a-development-branch`: verify, then merge, PR, keep or discard

Craft skills underneath: `systematic-debugging`, `verification-before-completion`,
`writing-skills`. Diagnosis: `diagnosing-superpowers`.

## The IaC loop: what RED, GREEN and evidence mean for HCL

| Step | For application code | For infrastructure |
|---|---|---|
| RED | A failing unit test | A failing `terraform test` assertion, or a Checkov check that fails on purpose. An undeclared resource is an error, not RED |
| GREEN | Minimal code to pass | The one block that makes the assertion pass |
| Evidence | Test output, zero failures | Test output, scan count, apply summary, destroy summary |
| Claim | "Tests pass" with the run in the same message | "Applied and clean" with all four in the same message |

## Skill versus gate

| | Workflow harness (M08) | Gate (M06, M09) |
|---|---|---|
| Runs | Because the bootstrap told the agent to check | Whether or not the agent read anything |
| Can | Make the right process very hard to skip | Make the dangerous moment impossible |
| Keep | Both. The harness is how the agent arrives at the pipeline with a plan, a test and evidence | |

## Superpowers or GSD

| The job | Reach for |
|---|---|
| One change, one session | Superpowers alone |
| A feature that needs a design doc and a plan | Superpowers, sized as a project |
| A multi-phase build across many sessions | GSD on top (Discuss, Plan, Execute, Verify, Ship per milestone), Superpowers underneath |

gsd-core installs with `npx @opengsd/gsd-core@latest`. Fresh-context subagents against context
rot; state in `STATE.md` and `CONTEXT.md` across sessions.

## Harness before loop

Never add a loop on top of a broken harness. M12's step 5 only works once the harness under it
catches what a human would have caught. This module is still step 4.
