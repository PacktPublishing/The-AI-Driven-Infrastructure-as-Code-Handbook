# Module 7: Spec-Driven Infrastructure

**Type:** hands-on · **Lab tier:** 1 · **Duration:** ~55 min · **Book chapter:** 7

Write the intent down properly, before anything gets generated. This module teaches the
difference between a one-line intent (M01) and a real spec: requirements, constraints, and
acceptance criteria, stated before generation. It also names vibe coding, once, as a
failed approach on infrastructure, with a concrete, real, checkable failure, not a vibe.

## Delivery guide

| # | Lecture | Source | ~min |
|---|---|---|---|
| 1 | What a spec has that an intent doesn't | `reading/concepts.md` sections 1-2 | 5 |
| 2 | Vibe coding, named | `reading/concepts.md` §3 | 4 |
| 3 | Spec Kit and Kiro specs | `reading/concepts.md` §4 | 4 |
| 4 | Generate against a spec, then check it | `reading/concepts.md` §5 | 5 |
| 5 | Spec vs gate vs policy | `reading/concepts.md` §6 | 5 |
| 6 | When it's worth writing one | `reading/concepts.md` §7 | 4 |
| 7 | Project: write a spec, generate, check the criteria | `LAB.md` | 20 |

Udemy: cut lectures 1-6 at 3-6 minutes each from the slide voiceover script
(`planning/voiceover/m07-slide-voiceover.md`); the lab is a single longer hands-on segment.

## Autonomy step

No new step introduced. Stays at step 3, propose with plan, same as M04/M05/M06. This
module improves the *proposal* (the spec), not the amount of supervision the agent runs
under.

## Definition-of-done status

- [x] `specs/M07-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root
      `LAB.md`, `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, ends with `terraform
      destroy` as a numbered step for both the spec-driven and vibe-coded modules
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/07-spec-driven-infra.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] Lectures cut 3-6 min in the Udemy table above
- [x] Autonomy step named (still step 3, explicitly stated as not moving up)
- [x] No retired tools presented as current
- [x] "Vibe coding" named once, as a failed approach, with a concrete stated failure,
      never recommended; not used anywhere else in this course
- [x] Every statistic matches the fact-discipline table in the course `CLAUDE.md` (none
      introduced in this module beyond callbacks to M01, stated as callbacks not restated
      as new claims)
- [x] Diagram beats: 6 hand-drawn SVGs in `explainer/diagrams/`, matching the established
      visual contract, verified via real Playwright screenshots of every deck slide
- [x] Course slide voiceover script: `planning/voiceover/m07-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, real terraform/checkov, exits non-zero on any
      regression

## Real bugs found and fixed while building this module

1. **`build_deck.py`'s `load_diagram()`** used the M06-derived fuzzy-title-match fix from
   the start (never regressed to the unconditional-strip version).
2. **Curved `<path>` elements defaulting to `fill="black"`.** Every diagram SVG in this
   module had at least one open curved path with no explicit `fill="none"`, which rendered
   as a solid black wedge instead of a thin line under the `#rough` filter. Fixed across
   all 6 diagrams, verified via real Playwright screenshots of every slide.
3. **A flat `<path>` inside a `filter`-bearing wrapping `<g>` is invisible in Chromium.**
   Same root cause as the known near-zero-bbox line bug, but on a code path
   `fix_thin_paths()` doesn't reach, since the filter sits on an ancestor `<g>`, not the
   `<path>` tag itself. Found on this module's own title slide, fixed by moving the filter
   onto the `<path>` element directly. This same bug is confirmed already live in M06's
   shipped title slide (its "apply attempted, gate checkpoint" connecting arrow is
   invisible), flagged here for a follow-up pass across M01 through M06 and M09's title
   slides, not fixed in those modules, out of this module's scope.
