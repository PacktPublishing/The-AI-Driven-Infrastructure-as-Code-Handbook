# M05: MCP and the Tool Layer

**Type:** hands-on · **Build order:** lab first · **Duration:** ~55 min ·
**Lab tier:** 1 · **Book chapter:** 5 · **Autonomy step introduced:** none new, still step 3

Real data in, not a better guess. Where M04 gave the agent a skill it reaches for on its
own, this module gives it a live connection to real systems, through a shared protocol,
so it can read real state instead of guessing from stale training data.

## What's in this module

```
modules/module-05-mcp-tool-layer/
  README.md               this file, delivery guide
  explainer/
    sim/
      stale-vs-live-sim.html   interactive stale-vs-live lookup simulator
  LAB.md                   Project 05: Build an RDS Module Using the Terraform MCP Server (Tier 1, ~40 min)
  lab/
    mcp-config/             real terraform.mcp.json and github.mcp.json
    module/                  the RDS module the lab applies against Floci: network, db, provider stub
    evidence/                real captured before/after answers and PR open/close JSON
    run.sh                   validates the image, config, and evidence for real, no secrets needed
  reading/
    concepts.md              ~15 min standalone read, the spine of Chapter 5 of the book
    reference.md              one-page A4 cheat sheet
    diagrams/                8 hand-drawn SVGs, one per section of concepts.md
  QUIZ.md                  7 questions, collapsible answers
  PROJECTS.md              3 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 55 minutes with a break. Each step walks one or two sections of
`reading/concepts.md` with its diagram from `reading/diagrams/` on screen:

1. "Before MCP: One-Off Integrations" and "MCP: One Protocol, Many Clients"
   (`before-mcp-tangled.svg`, `after-mcp-spokes.svg`), ~6 min.
2. "What an MCP Tool Call Actually Is" (`skill-hook-mcp.svg`), skill vs hook vs MCP, ~5 min.
3. "Stale Training Data Is a Real Failure Mode" and "A Live Lookup Can Build the Real Thing"
   (`stale-vs-live.svg`, `param-group-build.svg`), the module's centerpiece, ~6 min. Demo
   `explainer/sim/stale-vs-live-sim.html` at the "Try it" subsection.
4. "Official Doesn't Mean Ready", "Opening a Pull Request Is Not Merging It" and "Still
   Step 3" (`aws-iac-mcp-honest.svg`, `pr-not-merge.svg`, `still-step3.svg`), ~6 min.
5. "MCP Servers Are Still a Permission Surface", the lab bridge, ~2 min.
6. Break, then run `LAB.md` live, ~20 min. Real Terraform MCP server, real before/after
   answers, a real pull request opened and closed against a throwaway branch.
7. Close on the exercise: register one more real MCP server, capture one real answer.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless running a longer
format.

## Running the lab yourself first

Before you deliver this module, run the lab's real, secret-free check once:

```
cd modules/module-05-mcp-tool-layer/lab
./run.sh
```

Pulls and runs the real `hashicorp/terraform-mcp-server` image, validates both MCP config
files, and checks the real captured evidence in `lab/evidence/`: a genuinely low-confidence
guess, a genuine MCP tool citation, and a real pull request that opened then closed without
merging. This script doesn't need live credentials because it validates the evidence
already captured while building this module, the parts of the lab that DO need your own
GitHub token stay in `LAB.md` for you to run live.

## A note on how the evidence in this module was captured

The stale-vs-live comparison (3.6.2 guessed, 4.5.0 real) and the PR open-then-close
sequence (`lab/evidence/pr-opened.json`, `lab/evidence/pr-closed.json`) are real, not
staged: run against the actual `hashicorp/terraform-mcp-server` Docker image and the actual
GitHub MCP server, against a real throwaway branch on the course labs repo, closed
afterward without merging. Reproducing them requires Docker and a `gh`-authenticated
GitHub account, both real prerequisites, stated in `LAB.md`.

## Autonomy ladder

No new step. Still step 3, propose with plan, same as M04. MCP adds capability, real tool
calls and live data, it does not move a workflow up the ladder. A human still reads
everything the agent produces before anything real happens.

## Definition-of-done status

- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as the draft of
      Chapter 5 of the book
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 3 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] The Terraform MCP server used is HashiCorp's official server, the real Docker image,
      never the deprecated `awslabs/terraform-mcp-server`
- [x] The PR opened in the lab was real, confirmed via a direct GitHub API call independent
      of the MCP tool that opened it, and stayed unmerged, a human decision
- [x] Skill vs hook vs MCP distinction is precise, MCP is never blurred into "just another
      skill"
- [x] No new autonomy step introduced or implied
- [x] Diagrams: 8 hand-drawn SVGs in `reading/diagrams/`, same visual contract as
      M01/M03/M04/M06
- [x] Lab validation script: `lab/run.sh`, checks the real evidence end to end, no secrets
      required
- [x] Zero "rung" anywhere in learner-facing content (grepped, confirmed)
- [x] Simulator: `explainer/sim/stale-vs-live-sim.html`, the stale-vs-live lookup, embedded
      at the "Try it" subsection of `reading/concepts.md`

## Delivery guide: Udemy

This module's lecture cut mirrors M01/M03/M04/M06's pattern: one concept per lecture, 3-6
minutes each, following the ten sections of `reading/concepts.md`. `LAB.md` ships as a
standalone hands-on lecture after the concept lectures. `QUIZ.md` publishes as the module's
Udemy quiz. `PROJECTS.md` publishes as downloadable resources. The stale-vs-live simulator
ships as an embedded interactive alongside the lesson page.
