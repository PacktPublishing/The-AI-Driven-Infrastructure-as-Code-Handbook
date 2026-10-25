# M12: Loop Engineering for Infrastructure Agents

**Type:** hands-on · **Build order:** lab first · **Duration:** ~60 min ·
**Lab tier:** 0 · **Book chapter:** 12 · **Autonomy step introduced:** step 6, unattended,
closing the ladder

Every module from M02 to M11 built a piece of the harness or a gate in the pipeline. This module
builds the third layer from M01: the loop, what re-invokes an agent and what makes it stop. It
teaches loop engineering the way practitioners use the term in 2026: Huntley's Ralph loop, the
`ralph-loop` plugin, `/goal`, Stop hooks, `/loop` and the durable schedulers, in Claude Code and
in Codex. Then it adds the one thing infrastructure needs that a coding loop can get away
without: the loop's "done" is decided by the pipeline, not by the agent's transcript. A Stop hook
runs a scanner-backed `verify.sh`, and a guard hook stops the agent editing it.

Spec: [`specs/M12-spec.md`](../../specs/M12-spec.md). Read it before changing anything here.
Why this module was rewritten on 2026-10-25: [`decisions/0008-teach-real-loop-engineering.md`](../../decisions/0008-teach-real-loop-engineering.md).
The directory keeps its old name so published paths do not move.

## Versions shown on screen

| Tool | Version | Where it is pinned |
|---|---|---|
| Claude Code | 2.1.308 | `claude --version`, Appendix A |
| Codex CLI | 0.162.1 | `codex --version`, Appendix A |
| Terraform | 1.14.8 | Appendix A |
| Checkov | 3.3.30 | Appendix A |
| Python 3 with PyYAML | any current Python 3 | `run.sh` parses the workflow example with PyYAML |
| actionlint | 1.7.12, optional | `run.sh` skips the workflow lint without it |
| Model for the Claude runs | `claude-opus-5-5` | `lab/evidence/*.jsonl` |

## What's in this module

```
modules/module-12-loop-multiagent-economics/
  README.md                this file, delivery guide
  explainer/
    EXPLAINER.md            14 beats, narrator notes, timing
    deck/
      build_deck.py          generator, same lineage as M08
      m12-loop-multiagent-economics.html   16-slide self-contained deck
      m12-sequence.md        slide table, coverage check, diagram-to-figure map
    diagrams/                7 hand-drawn SVGs, the same files as book/figures/12/
    sim/
      stopping-condition-sim.html       who decides "done": phrase, /goal evaluator or Stop gate
      stopping-condition-sim.test.mjs
  LAB.md                    Project 12: Build an Infrastructure Loop That Only the Pipeline Can End (Tier 0, ~40 min)
  lab/
    .gitignore
    run.sh                   validates everything that needs no agent; M12_LIVE_AGENT=1 adds one real gated run
    loop/
      verify.sh              the stopping condition: exit 0 done, 1 not done, 2 no verdict
      hooks/stop-gate.sh     Stop hook: the agent may stop only when verify.sh says done
      hooks/guard-oracle.sh  PreToolUse hook: no edits to loop/, .claude/, .codex/ or .loop/
      install.sh             copies the loop into a working copy and registers both hooks
      claude-settings.json   hook registration for Claude Code
      codex-hooks.json       hook registration for Codex
      trace.py               prints tool calls, sends back, turns and cost from a stream-json run
    starter/                 log-shipper module with two hardcoded keys: main.tf and shipper.tf
      .gitignore  main.tf  shipper.tf
    solution/                both keys moved to sensitive variables, plus the nightly workflow
      .gitignore  main.tf  shipper.tf  trigger-workflow.example.yml
    finops/
      gate.py                FinOps gate: resource count, required tags, allowed instance types
      test_gate.py           15 unit tests
      plan-over-budget.json  plan-in-budget.json  plan-empty.json  plan-nested.json
    evidence/                every capture in LAB.md, as produced during the build
      goal-run1..3.trace.txt  hook-run1..3.trace.txt
      stage2-goal.jsonl  stage2-trace.txt  stage2-verify-after.txt
      stage3-hook.jsonl  stage3-state.md  stage3-trace.txt
      stage4-codex-untrusted.txt  stage4-codex-hooks-prompt.txt  stage4-codex-hook-detail.txt
      stage4-codex-trusted.txt  stage4-codex-state.md
      stage5-loop.txt  stage5-state.md
  reading/
    concepts.md              the chapter draft, the same body as book/chapters/12-loop-multiagent-economics.md
    reference.md             one-page cheat sheet
    diagrams/                the same 7 SVGs, for the reading
  QUIZ.md                   10 questions, collapsible answers
  PROJECTS.md               5 stretch projects
```

`lab/finops/__pycache__/` appears after the tests run and is ignored by `lab/.gitignore`.

## Delivery guide: live workshop

Run in this order, roughly 75 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1 to 3 (the story, the third layer, harness first), ~6 min.
2. Walk beats 4 to 6 (where it came from, the six parts, four primitives), ~8 min. Keep the
   dates on screen; the history is short and sourced.
3. Walk beat 7 (who decides "done"), ~5 min. This is the module. Then open the simulator and run
   the narrow ticket under all three judges.
4. Walk beat 8 (the gate in action), ~3 min.
5. Walk beats 9 to 12 (topologies, cost, step 6, the ladder), ~10 min. Say the JetBrains numbers
   with their date, setup and sample size.
6. Break, then run `LAB.md` live, ~40 min. Stage 3 is the moment people remember: the gate sends
   the agent back for a key it was never asked about. In Stage 4, run `codex exec` before
   trusting the hooks and let the room see the empty state file.
7. Close on PROJECTS.md seed 1: wrap one of their own checks.

Agent runs are not deterministic. Turn counts and costs will differ from the captures. Show
the captures in `lab/evidence/` if a live run goes another way, and say so.

`QUIZ.md` and `PROJECTS.md` are take-home unless running a longer format.

## Running the lab yourself first

```
cd modules/module-12-loop-multiagent-economics/lab
./run.sh
```

Requires `terraform`, `checkov`, `git` and `python3` with PyYAML; uses `actionlint` when present.
It checks the verifier's three exits (both keys on the starter, the solution clean, a
`checkov:skip` refused, no verdict on a broken provider block), the Stop gate and guard directly,
the block budget, `trace.py` on a captured run, the FinOps gate and its tests, and the workflow
example. With `M12_LIVE_AGENT=1` it also runs one real gated Claude Code session, which must end
with `done` in `.loop/state.md` and agree with an independent `verify.sh`.

## Where the captures came from

Every agent capture in `LAB.md` and `lab/evidence/` was made on 25 October 2026 during the build.
Claude Code ran in a clean config directory with no plugins and no `CLAUDE.md`, using model
`claude-opus-5-5`. Codex ran with a clean `HOME` and `CODEX_HOME`. The authoring repository's own
`CLAUDE.md` and plugins were not loaded. Stages 2 and 3 were captured as
`claude -p --output-format stream-json` event logs and read back with `trace.py`; the three runs
of each judge are kept as `goal-run*.trace.txt` and `hook-run*.trace.txt`. Stage 4 was captured
from `codex exec` before and after trusting the hooks, and the trust prompt from an interactive
session. Stage 5 was driven in a real interactive `claude` session with `/loop 2m`, with drift
committed from a second terminal. Nothing was edited to look better.

## Autonomy ladder

Step 6, unattended, closing the ladder. A gated loop like this one is how step 5, supervised
autonomy, works in practice. A scheduled gated loop is step 6: no human approves each run, and a
person appears only on an exception. The module states what has to be true first (a gate from M06,
a workflow harness from M08, a pipeline from M09) and never teaches step 6 as a default.

## Delivery guide: Udemy

One concept per lecture, 3 to 6 minutes each.

| # | Lecture | Slides | ~min |
|---|---|---|---|
| 1 | The Third Layer, Built Last on Purpose | 1 to 3 | 5 |
| 2 | Where Loop Engineering Came From | 4 | 4 |
| 3 | The Six Parts of a Loop and Four Primitives | 5, 6 | 6 |
| 4 | Who Decides "Done"? | 7, 8 | 5 |
| 5 | The Stop Gate in Action | 9 | 4 |
| 6 | Loop Topologies: One Agent or Several | 10, 11 | 4 |
| 7 | What a Loop Costs | 12 | 5 |
| 8 | Step 6, Unattended, and the Ladder Closed | 13 to 15 | 5 |
| 9 | Lab: Build the Stopping Condition | LAB Stage 1 | 4 |
| 10 | Lab: A Loop the Model Judges | LAB Stage 2 | 5 |
| 11 | Lab: A Loop the Pipeline Judges | LAB Stage 3 | 6 |
| 12 | Lab: The Same Loop in Codex | LAB Stage 4 | 6 |
| 13 | Lab: Put the Loop on a Clock | LAB Stage 5 | 6 |
| 14 | Lab: What It Cost, and a FinOps Gate | LAB Stage 6 | 5 |

Lectures 9 to 14 are screen-recorded; Stages 4 and 5 need interactive sessions. `QUIZ.md`
publishes as the module's Udemy quiz. `PROJECTS.md`, `reading/reference.md`, `lab/loop/` and
`lab/solution/trigger-workflow.example.yml` publish as downloadable resources. The Module 12
lectures recorded before 2026-10-25 are retired; re-record from
`planning/voiceover/m12-slide-voiceover.md`.

## Definition-of-done status

- [x] `specs/M12-spec.md` and `decisions/0008-teach-real-loop-engineering.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 0, real captured output only
- [x] Every loop runs a real agent; no hardcoded fix
- [x] The `/goal` result and the gated result both shown honestly
- [x] `reading/concepts.md` is the chapter draft. At about 6,000 words it is closer to a
      25-minute read than 15, because it carries the full chapter body
- [x] `reading/reference.md` is a one-page cheat sheet
- [x] `QUIZ.md`: 10 questions, collapsible answers
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live and Udemy delivery guide, lectures cut at 3 to 6 minutes
- [x] Origin dates stated with sources; token-tool numbers stated with date, setup and sample size
- [x] Step 6 stated precisely, with what has to be true first
- [x] No retired tools presented as current
- [x] Course slide voiceover script: `planning/voiceover/m12-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`
- [x] Simulator test: `node --test explainer/sim/*.test.mjs`
