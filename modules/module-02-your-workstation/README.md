# M02: Your Agentic IaC Workstation

**Type:** hands-on · **Build order:** lab first · **Duration:** ~65 min ·
**Lab tier:** 0 · **Book chapter:** 2 · **Autonomy steps introduced:** step 1 (suggest), step 2 (draft)

Module 1 was theory, no installs. This module is where the learner's machine becomes an
agentic IaC workstation for real: Claude Code and Codex CLI installed side by side, the
pinned tool versions from Environment Setup verified, and the same one-line intent from
module 1's lab run through a real agent three times, suggest, draft, and extended under
`acceptEdits`, plus a bounded subagent delegation and a real custom slash command, so real
agent-driving skill is felt directly, not just read about.

Spec: [`specs/M02-spec.md`](../../specs/M02-spec.md). Read it before changing anything here.

## What's in this module

```
modules/module-02-your-workstation/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           8 diagram beats, narrator notes, timing
    deck/
      build_deck.py         generator, strict load_diagram() title-match pattern
      m02-your-workstation.html  17-slide self-contained deck
      m02-sequence.md        slide table, fragment map, coverage check
    diagrams/               7 hand-drawn SVGs (title slide has its own inline SVG)
    sim/
      permission-mode-sim.html   interactive permission-mode simulator, embedded in the lesson
  LAB.md                   Project 02: Build an Nginx Test Module Using Claude Code's Agent Modes (Tier 0, ~20 min)
  lab/
    starter/main.tf          intent-only, nothing to complete by hand
    solution/
      step1-suggested/        real captured suggestion, hand-typed, with its real bugs fixed
      step2-drafted/           real captured agent-written draft, same real bug, fixed
      step3-acceptedits/       real captured acceptEdits extension, plus a real slash command
    run.sh                   validates all three, plan-clean, checkov-clean, and genuinely differ
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/02-your-workstation.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  9 questions, collapsible answers
  PROJECTS.md              4 stretch project seeds, including an Ansible bonus
```

## Delivery guide: live workshop

Run in this order, roughly 65 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1-5 (why two CLIs, the pinned tool versions), ~5 min.
2. Walk beats 6-11 (step 1 suggest, step 2 draft, what actually differed), ~8 min.
3. Walk beats 12-13 (acceptEdits, subagents, a slash command), ~5 min.
4. Walk beats 14-16 (where config will live, closing), ~3 min.
5. Break, then run `LAB.md` live, ~20 min. Learners need their own agent CLI authenticated.
6. Close on the exercise: which step would you hand to a machine without watching.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless running a longer format.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-02-your-workstation/lab
./run.sh
```

Requires `terraform`, `checkov`, and Docker reachable at `/var/run/docker.sock`. It validates
all three solutions for real (fmt, init, validate, **plan**, checkov), asserts every
`local_file`/`host_path` reference wraps `path.module` in `abspath()` (the real bug this module
found), asserts `step1-suggested` and `step2-drafted` genuinely differ, and checks the
`step3-acceptedits/.claude/commands/tf-check.md` slash command is present and well-formed.

## Autonomy ladder

Steps 1 and 2, suggest and draft, the two lowest steps on the ladder, the ones where the
learner keeps the most direct, physical control: every keystroke in step 1, every line read
before anything runs in step 2. `acceptEdits` sits between step 2 and step 3 (propose with
plan, previewed here and taught properly from M04): more autonomy than draft-and-read-once,
still short of a plan the learner approves before anything moves.

## Definition-of-done status

- [x] `specs/M02-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 0, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/02-your-workstation.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 9 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 4 stretch project seeds, hints not solutions, including an Ansible bonus
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] Both CLIs are actually installed and version-checked; Claude Code's step 1/step 2 run was
      actually executed and captured for real (Codex CLI is present in this environment but
      resolves as a shell function unavailable to non-interactive automation, so its own
      captured session was not possible here, noted honestly rather than fabricated, see
      `reading/concepts.md`'s "A Workstation, Not One Tool" section)
- [x] The pinned-tool verify step matches module 1's own Tier 0 pre-requisites exactly
- [x] Step 1 and step 2 are demonstrated on the identical intent from module 1's lab, not a new
      one
- [x] No tool beyond Claude Code, Codex CLI, and Environment Setup's existing pins is
      introduced here
- [x] Diagram beats: 7 hand-drawn SVGs in `explainer/diagrams/`, same visual contract as
      M01/M03/M04/M06/M09
- [x] Deck: 17 self-contained slides, zero external refs, `_looks_like_title` uses the strict
      exact-match-or->0.75-ratio check (not loose substring containment), verified
      programmatically that every source SVG's real `<text>` content survived into the deck,
      zero missing diagram labels, zero invisible-line regressions
- [x] Course slide voiceover script: `planning/voiceover/m02-slide-voiceover.md` (needs a pass
      for the two new slides added this round, not yet re-recorded)
- [x] Lab validation script: `lab/run.sh`, checks all three real solution runs (plan-clean,
      checkov-clean, abspath present), and step1/step2's genuine divergence
- [x] Zero occurrences of "rung" anywhere in learner-facing content, "step" used throughout,
      per the course-wide terminology decision from M01
- [x] Interactive simulator: `explainer/sim/permission-mode-sim.html`, embedded inline in
      `reading/concepts.md` via the site's `Embed` component, matching every module in this
      course's actual sim coverage

## Delivery guide: Udemy

This module's lecture cut mirrors the established pattern: one concept per lecture, 3-6 minutes
each, following the deck's 8 sections. `LAB.md` ships as a standalone hands-on lecture after the
concept lectures. `QUIZ.md` publishes as the module's Udemy quiz. `PROJECTS.md` publishes as
downloadable resources.
