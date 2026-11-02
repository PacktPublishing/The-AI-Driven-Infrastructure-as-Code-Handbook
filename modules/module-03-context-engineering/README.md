# M03: Context Engineering for Infrastructure

**Type:** hands-on · **Build order:** lab first · **Duration:** ~55 min ·
**Lab tier:** 0 → 1 · **Book chapter:** 3 · **Autonomy step introduced:** none new,
still step 2 (draft)

The CONTEXT layer of M01's three-layer model, taught for real. The symptom that
points here: "the agent can't get one task right at all." The fix: give the agent
the same standing information a new hire would get on day one, an `AGENTS.md`, not
a bigger model or a cleverer prompt.

## What's in this module

```
modules/module-03-context-engineering/
  README.md               this file, delivery guide
  explainer/
    sim/
      context-window-sim.html   interactive context window visualizer
  LAB.md                   Project 03: Manage Context for an Nginx Module Using AGENTS.md and STATE.md (Tier 0-1, ~15 min)
  lab/
    starter/main.tf          run 1, no AGENTS.md, fails checkov same as M01
    solution/main.tf         run 2, with AGENTS.md, checkov-clean
    solution/AGENTS.md       the written context file itself
    run.sh                   validates both runs + AGENTS.md structure, for real
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, the spine of Chapter 3 of the book
    reference.md              one-page A4 cheat sheet
    diagrams/                10 hand-drawn SVGs, one per section of concepts.md
  QUIZ.md                  7 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 55 minutes with a break. Each step walks one or two sections of
`reading/concepts.md` with its diagram from `reading/diagrams/` on screen:

1. "Recap", "The Context Window Is a Scarce Resource" and "Context Engineering Is Three
   Disciplines, Not One" (`context-window.svg`, `three-r.svg`), ~5 min. Demo
   `explainer/sim/context-window-sim.html` at the "Try it" subsection.
2. "Reduce", "Retain" and "Route" (`reduce-compact.svg`, `agentsmd-anatomy.svg`,
   `retrieval-funnel.svg`, `route-wall.svg`), the anatomy and the retrieval funnel, ~4 min.
3. "The Information Gap" (`information-gap.svg`), "Context Engineering, Not Prompt
   Engineering" (`context-vs-prompt.svg`) and "Before and After" (`before-after.svg`),
   ~4 min. Say the "11 of 14, not 79%" caveat out loud, it's part of the material.
4. The callback to M01's three layers (`three-layers-context.svg`), ~1 min.
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
`AGENTS.md` has all five required sections.

## Autonomy ladder

No new step. The lab keeps the learner at step 2, draft, the same as M01, human
reads every line either way. What changes is what the agent had available before it
wrote those lines.

## Definition-of-done status

- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root
      `LAB.md`, `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 0-1, real captured
      output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as the draft of
      Chapter 3 of the book
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] No "prompt engineering" used as the umbrella term anywhere in this module
- [x] The 11/14 fraction stated correctly everywhere it appears (not rounded to 79%)
- [x] The recap calls back explicitly to M01's three-layer model
      (`reading/diagrams/three-layers-context.svg`)
- [x] The before/after diff in the lab is real, captured `diff -u` output
- [x] Diagrams: 10 hand-drawn SVGs in `reading/diagrams/`, same visual contract as M01
- [x] Lab validation script: `lab/run.sh`, checks both runs + AGENTS.md structure

## Delivery guide: Udemy

This module's lecture cut mirrors M01's pattern: one concept per lecture, 3-6 minutes
each, following the eight sections of `reading/concepts.md`. `LAB.md` ships as a
standalone hands-on lecture after the concept lectures. `QUIZ.md` publishes as the module's Udemy quiz.
`PROJECTS.md` publishes as downloadable resources.
