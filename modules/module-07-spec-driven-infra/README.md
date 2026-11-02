# Module 7: Spec-Driven Infrastructure

**Type:** hands-on · **Lab tier:** 1 · **Duration:** ~55 min · **Book chapter:** 7

Write the intent down properly, before anything gets generated. This module teaches the
difference between a one-line intent (M01) and a real spec: requirements, constraints, and
acceptance criteria, stated before generation. It also names vibe coding, once, as a
failed approach on infrastructure, with a concrete, real, checkable failure, not a vibe.

## What's in this module

```
modules/module-07-spec-driven-infra/
  README.md               this file, delivery guide
  explainer/
    sim/
      spec-vs-vibe-sim.html   interactive spec-driven vs vibe-coded comparison
  LAB.md                   Project 07: Build an Autoscaling Web Tier Using Spec-Driven Development (Tier 1, ~30 min)
  lab/
    spec-driven/             spec.md and the module generated against it, Floci provider stub
    vibe-coded/              the same intent generated from one line, no spec
    evidence/                real checkov output for both, and the real plan diff
    run.sh                   real terraform/checkov, exits non-zero on any regression
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, the spine of Chapter 7 of the book
    reference.md             one-page A4 cheat sheet
    diagrams/                6 hand-drawn SVGs, one per section of concepts.md
  QUIZ.md                  9 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide

| # | Lecture | Source in `reading/concepts.md` | Diagram in `reading/diagrams/` | ~min |
|---|---|---|---|---|
| 1 | What a spec has that an intent doesn't | "Recap", "What a Spec Has That an Intent Doesn't" | `intent-vs-spec.svg` | 5 |
| 2 | Vibe coding, named | "Vibe Coding, Named" | `vibe-coding-loop.svg` | 4 |
| 3 | Spec Kit and Kiro specs | "Spec Kit and Kiro Specs" | `spec-kit-workflow.svg` | 4 |
| 4 | Generate against a spec, then check it | "Generate Against a Spec, Then Check It, Line by Line" | `generate-against-spec.svg` | 5 |
| 5 | Spec vs gate vs policy | "Spec vs Gate vs Policy: Three Different Jobs" | `spec-gate-policy.svg` | 5 |
| 6 | When it's worth writing one | "When It's Worth Writing One", "One Language, Two Runtimes" | `when-worth-it.svg` | 4 |
| 7 | Project: write a spec, generate, check the criteria | `LAB.md` | | 20 |

Udemy: cut lectures 1-6 at 3-6 minutes each, one section of `reading/concepts.md` per
lecture with its diagram on screen; the lab is a single longer hands-on segment. Demo
`explainer/sim/spec-vs-vibe-sim.html` at lecture 4's "Try it" subsection; it ships as an
embedded interactive alongside the lesson page.

## Autonomy step

No new step introduced. Stays at step 3, propose with plan, same as M04/M05/M06. This
module improves the *proposal* (the spec), not the amount of supervision the agent runs
under.

## Definition-of-done status

- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root
      `LAB.md`, `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, ends with `terraform
      destroy` as a numbered step for both the spec-driven and vibe-coded modules
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as the draft of
      Chapter 7 of the book
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 9 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] Lectures cut 3-6 min in the Udemy table above
- [x] Autonomy step named (still step 3, explicitly stated as not moving up)
- [x] No retired tools presented as current
- [x] "Vibe coding" named once, as a failed approach, with a concrete stated failure,
      never recommended; not used anywhere else in this course
- [x] Every statistic follows the course's fact discipline (none introduced in this module
      beyond callbacks to M01, stated as callbacks not restated as new claims)
- [x] Diagrams: 6 hand-drawn SVGs in `reading/diagrams/`, matching the established visual
      contract
- [x] Lab validation script: `lab/run.sh`, real terraform/checkov, exits non-zero on any
      regression
