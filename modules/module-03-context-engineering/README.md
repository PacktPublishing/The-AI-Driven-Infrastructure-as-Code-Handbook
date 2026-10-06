# M03: Context Engineering for Infrastructure

**Type:** hands-on · **Build order:** lab first · **Duration:** ~55 min ·
**Lab tier:** 0 → 1 · **Book chapter:** 3 · **Autonomy step introduced:** none new,
still step 2 (draft)

The CONTEXT layer of M01's three-layer model, taught for real. The symptom that
points here: "the agent can't get one task right at all." The fix: give the agent
the same standing information a new hire would get on day one, an `AGENTS.md`, not
a bigger model or a cleverer prompt.

Spec: [`specs/M03-spec.md`](../../specs/M03-spec.md). Read it before changing
anything here.

## What's in this module

```
modules/module-03-context-engineering/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           8 diagram beats, narrator notes, timing
    deck/
      build_deck.py         generator, mirrors M01's own generator
      m03-context-engineering.html  19-slide self-contained deck
      m03-sequence.md        slide table, fragment map, coverage check
    diagrams/               7 hand-drawn SVGs (beat 1 has no diagram, title only)
  LAB.md                   Project 03: Manage Context for an Nginx Module Using AGENTS.md and STATE.md (Tier 0-1, ~15 min)
  lab/
    starter/main.tf          run 1, no AGENTS.md, fails checkov same as M01
    solution/main.tf         run 2, with AGENTS.md, checkov-clean
    solution/AGENTS.md       the written context file itself
    run.sh                   validates both runs + AGENTS.md structure, for real
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/03-context-engineering.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  7 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 55 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1-3 (the recap, the scarce window, context vs
   prompt), ~5 min.
2. Walk beats 4-5 (the anatomy, the retrieval funnel), ~4 min.
3. Walk beats 6-7 (the information gap, before/after), ~4 min. Say the "11 of 14, not
   79%" caveat out loud, it's part of the material.
4. Walk beat 8 (the callback), ~1 min.
5. Break, then run `LAB.md` live, ~15 min, everyone on their own machine and their own
   agent. Run 1, write the file, run 2, diff.
6. Close on the lab's "Which failure was which" section, it's the hinge into M06.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless running a longer
format.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-03-context-engineering/lab
./run.sh
```

Requires `terraform`, and `checkov` (pin `3.3.16`, matching Environment Setup; if it's
not on `PATH`, install into a scratch venv first). Expect: run 1 (no
`AGENTS.md`) fails checkov on `CKV_SECRET_2`, run 2 (with `AGENTS.md`) is clean,
`AGENTS.md` has all four required sections.

## Autonomy ladder

No new step. The lab keeps the learner at step 2, draft, the same as M01, human
reads every line either way. What changes is what the agent had available before it
wrote those lines.

## Definition-of-done status

- [x] `specs/M03-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root
      `LAB.md`, `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 0-1, real captured
      output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/03-context-engineering.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] No "prompt engineering" used as the umbrella term anywhere in this module
- [x] The 11/14 fraction stated correctly everywhere it appears (not rounded to 79%)
- [x] Beat 8 / slide 17 explicitly calls back to M01's three-layer diagram
- [x] The before/after diff in the lab is real, captured `diff -u` output
- [x] Diagram beats: 7 hand-drawn SVGs in `explainer/diagrams/`, same visual contract
      as M01
- [x] Deck: 19 self-contained slides, zero external refs, real Playwright render check
- [x] Course slide voiceover script: `planning/voiceover/m03-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, checks both runs + AGENTS.md structure

## Delivery guide: Udemy

This module's lecture cut mirrors M01's pattern: one concept per lecture, 3-6 minutes
each, following the deck's 8 sections. `LAB.md` ships as a standalone hands-on lecture
after the concept lectures. `QUIZ.md` publishes as the module's Udemy quiz.
`PROJECTS.md` publishes as downloadable resources.
