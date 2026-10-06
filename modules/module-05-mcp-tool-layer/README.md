# M05: MCP and the Tool Layer

**Type:** hands-on · **Build order:** lab first · **Duration:** ~55 min ·
**Lab tier:** 1 · **Book chapter:** 5 · **Autonomy step introduced:** none new, still step 3

Real data in, not a better guess. Where M04 gave the agent a skill it reaches for on its
own, this module gives it a live connection to real systems, through a shared protocol,
so it can read real state instead of guessing from stale training data.

Spec: [`specs/M05-spec.md`](../../specs/M05-spec.md). Read it before changing anything here.

## What's in this module

```
modules/module-05-mcp-tool-layer/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           7 diagram beats, narrator notes, timing
    deck/
      build_deck.py         generator, mirrors M01/M03/M04/M06's own generator
      m05-mcp-tool-layer.html   13-slide self-contained deck
      m05-sequence.md        slide table, fragment map, coverage check
    diagrams/               6 hand-drawn SVGs (title slide has its own inline SVG)
  LAB.md                   Project 05: Build an RDS Module Using the Terraform MCP Server (Tier 1, ~40 min)
  lab/
    mcp-config/             real terraform.mcp.json and github.mcp.json
    evidence/                real captured before/after answers and PR open/close JSON
    run.sh                   validates the image, config, and evidence for real, no secrets needed
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/05-mcp-tool-layer.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  7 questions, collapsible answers
  PROJECTS.md              3 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 55 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1-2 (before/after MCP), ~6 min.
2. Walk beat 3 (skill vs hook vs MCP), ~5 min.
3. Walk beat 4 (the real before-and-after), the module's centerpiece, ~6 min.
4. Walk beats 5-6 (PR is not merge, still step 3), ~6 min.
5. Walk beat 7 (the lab bridge), ~2 min.
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

- [x] `specs/M05-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/05-mcp-tool-layer.md`
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
- [x] Diagram beats: 6 hand-drawn SVGs in `explainer/diagrams/`, same visual contract as
      M01/M03/M04/M06, every diagram's real text verified present in the rendered deck
- [x] Deck: 13 self-contained slides, zero external refs, real Playwright render check,
      zero invisible-line regressions
- [x] Course slide voiceover script: `planning/voiceover/m05-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, checks the real evidence end to end, no secrets
      required
- [x] Zero "rung" anywhere in learner-facing content (grepped, confirmed)
- [ ] No simulator this module, per spec: an install/configure module doesn't benefit from
      being driven the way a mechanism (blast radius, a pipeline) does

## Delivery guide: Udemy

This module's lecture cut mirrors M01/M03/M04/M06's pattern: one concept per lecture, 3-6
minutes each, following the deck's 6 sections. `LAB.md` ships as a standalone hands-on
lecture after the concept lectures. `QUIZ.md` publishes as the module's Udemy quiz.
`PROJECTS.md` publishes as downloadable resources.
