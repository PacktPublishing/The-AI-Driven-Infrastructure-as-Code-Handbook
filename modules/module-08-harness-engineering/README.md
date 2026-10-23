# M08: Harness Engineering

**Type:** hands-on · **Build order:** lab first · **Duration:** ~60 min ·
**Lab tier:** 1 · **Book chapter:** 8 · **Autonomy step introduced:** none new, still step 4, the
precondition for step 5 (supervised autonomy, M12)

Three things get called a harness: the runtime (Claude Code, Codex), the course's HARNESS layer
(M04 to M06), and a workflow harness, a skills library plus a bootstrap that makes the agent
follow an engineering process in every session. This module installs the real one,
[obra/superpowers](https://github.com/obra/superpowers), in both runtimes, shows how its bootstrap
works, runs one infrastructure change through its whole workflow, and positions OpenGSD for
bigger builds. The course's bottom-up rule still applies: never add a loop on top of a broken
harness.

Spec: [`specs/M08-spec.md`](../../specs/M08-spec.md). Read it before changing anything here.
Why this module was rewritten on 2026-10-22: [`decisions/0007-teach-real-superpowers.md`](../../decisions/0007-teach-real-superpowers.md).

## Versions shown on screen

| Tool | Version | Where it is pinned |
|---|---|---|
| Superpowers plugin | **7.0.0** in both runtimes (`superpowers@claude-plugins-official`). 7.0.1 shipped on 21 Oct 2026 and retunes brainstorming; the lab's behaviour is the same | `LAB.md` Stage 1, Appendix A |
| Claude Code | 2.1.304 | `claude --version` |
| Codex CLI | 0.162.1 | `codex --version` |
| Terraform | 1.14.8 (`terraform test` needs 1.6 or later) | Appendix A |
| Checkov | 3.3.30 | Appendix A |
| Floci | 1.7.0, pinned in `labs/shared/docker-compose.floci.yml` | Appendix A |

## What's in this module

```
modules/module-08-harness-engineering/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           9 diagram beats, narrator notes, timing
    deck/
      build_deck.py         generator, same lineage as M06/M07
      m08-harness-engineering.html   16-slide self-contained deck
      m08-sequence.md        slide table, diagram-to-figure map, coverage check
    diagrams/               8 hand-drawn SVGs
    sim/
      bootstrap-sim.html     plugin off or on, three requests, which skill fires first
      bootstrap-sim.test.mjs
  LAB.md                   Project 08: Run an IaC Change Through the Superpowers Workflow Harness (Tier 1, ~35 min)
  lab/
    orders/                  the starter: a bare DynamoDB table and a dynamodb:* policy, Floci provider stub
    solution/                the hardened module, its tests, and the design doc and plan the workflow produced
    skills/
      iac-verification/SKILL.md   the project skill Stage 4 adds to the harness
    evidence/                every capture in LAB.md, as produced during the build
    first-actions.py         prints the tool calls from a `claude -p --output-format stream-json` run, in order
    run.sh                   validates the full real sequence, including a real Floci apply/destroy
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, the seed of book/chapters/08-harness-engineering.md
    reference.md             one-page A4 cheat sheet
    diagrams/                the same 8 SVGs, for the reading
  QUIZ.md                  9 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 60 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beat 2 (three things called a harness), ~3 min. Do not skip
   it; every later confusion in this module traces back to the word.
2. Walk beats 3 and 4 (a skills library plus a bootstrap, the bootstrap path), ~7 min. Open the
   three real files on screen from the installed plugin directory.
3. Walk beat 5 (the basic workflow), ~3 min.
4. Walk beats 6 and 7 (the IaC loop, skill versus gate), ~6 min. Say the honest finding out
   loud: without the harness a strong model still tested; the harness made it uniform.
5. Walk beat 8 (Superpowers and GSD, stacked), ~3 min.
6. Walk beat 9 (harness before loop), ~2 min.
7. Break, then run `LAB.md` live, ~35 min. Stage 3 is interactive and is the part people
   remember: brainstorming asks, you answer, the plan appears, the test fails first.
8. Close on PROJECTS.md seed 1: port one of their own checklists into a skill.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless running a longer format.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-08-harness-engineering/lab
./run.sh
```

Requires `terraform`, `checkov`, and Docker reachable at `/var/run/docker.sock`. It confirms the
starter's tests fail as assertions (not as errors), the solution's tests pass, Checkov reports no
finding for the two hardening checks the tests cover, then pulls and runs `floci/floci:1.7.0`,
applies the solution for real, and destroys it. With `M08_LIVE_AGENT=1` it also runs the Claude
Code probe and asserts the Superpowers bootstrap answered.

## Where the captures came from

Every agent transcript in `LAB.md` was produced during the build from a learner-like
environment: a fresh Claude Code config directory and a fresh Codex home with nothing in them
but credentials, inside the companion repository checkout, which carries no `CLAUDE.md`. The
authoring repository's own `CLAUDE.md` and plugins were not loaded. Stage 2's two runs were
captured as `claude -p --output-format stream-json` event logs, kept verbatim under
`lab/evidence/`. Stage 3 was driven in a real interactive `claude` session and the pane captured.
Nothing was edited to look better.

## Autonomy ladder

No new step. Still step 4 in practice, but this module is what makes step 5 (supervised autonomy,
taught in M12) safe to attempt: a loop on top of a broken harness just repeats its mistakes faster.

## Definition-of-done status

- [x] `specs/M08-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and seeds
      `book/chapters/08-harness-engineering.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 9 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] Every skill name, file path, hook event and command exists in Superpowers 7.0.0, checked
      against the installed plugin directory
- [x] The three senses of harness named on slide 3 and in the first concept section
- [x] Stage 3's RED is an assertion failure, not an undeclared-resource error
- [x] OpenGSD positioned in one section with a decision table, not taught hands-on
- [x] No "superpowers pattern", no invented origin story, no regex Stop hook
- [x] No new autonomy step introduced; step 5 previewed as "what this makes possible"
- [x] Course slide voiceover script: `planning/voiceover/m08-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`
- [x] Zero "rung" anywhere in learner-facing content, "step" used throughout

## Delivery guide: Udemy

One concept per lecture, 3 to 6 minutes each, following the deck's 6 sections: three things
called a harness (slide 3), Superpowers and its bootstrap (slides 5 to 7), adapting it to
infrastructure (slides 9 to 10), bigger builds (slide 12), harness before loop (slide 14), and
the closing. `LAB.md` ships as four hands-on lectures, one per stage; Stage 3 is screen-recorded
from an interactive session. `QUIZ.md` publishes as the module's Udemy quiz. `PROJECTS.md`,
`reading/reference.md` and `lab/skills/iac-verification/SKILL.md` publish as downloadable
resources. The Module 8 lectures recorded before 2026-10-22 are retired; re-record from
`planning/voiceover/m08-slide-voiceover.md`.
