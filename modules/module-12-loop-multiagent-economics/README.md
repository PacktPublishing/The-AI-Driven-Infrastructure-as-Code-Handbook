# Module 12: Loop Engineering, Multi-Agent Ops, Economics

Conceptual module, explainer-first, closing the three-layer model and the autonomy ladder
before the capstone.

## Delivery guide

**Live workshop:** ~55 min. Walk the deck (16 slides, ~25 min), then the lab (~15 min), then
the quiz.

**Udemy:** split at divider boundaries. Suggested lecture cuts, all inside 3-6 minutes:

| # | Lecture | Slides | min |
|---|---|---|---|
| 1 | The third layer, finally | 1-3 | 4 |
| 2 | A loop needs two things | 4-5 | 4 |
| 3 | Step 6, unattended | 6-8 | 5 |
| 4 | Multiple agents, two shapes | 9-10 | 4 |
| 5 | The economics, checked | 11-12 | 4 |
| 6 | Closing the ladder | 13-16 | 5 |

## Files

```
reading/concepts.md       book chapter 12 draft, ~15 min standalone read
reading/reference.md      one-page cheat sheet
reading/diagrams/         synced copies of the 7 diagrams
explainer/diagrams/       7 hand-drawn SVGs
explainer/deck/           build_deck.py + generated 16-slide deck + sequence doc
explainer/EXPLAINER.md    narrator notes per beat
LAB.md                    Project 12: real stopping-condition loop + real trigger config
QUIZ.md                   7 MCQ, collapsible answers
PROJECTS.md               5 stretch projects
```

## Autonomy ladder

This module closes the ladder. No new step is exercised in the lab beyond what earlier Tier
1/2 labs already demonstrated (the lab's own loop is Tier 0, config and scripting only), but
step 6 is defined precisely for the first time, and all six steps are named together, with
their gates, in the closing content.

## Definition-of-done status

- [x] `specs/M12-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 0, real stopping-condition
      loop run 3 times with real, verified, different outcomes each time
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/12-loop-multiagent-economics.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-based
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] Lectures cut 3-6 min in the Udemy table above
- [x] Step 6 named precisely, all six steps closed out together
- [x] No retired tools presented as current
- [x] No "prompt engineering," no "vibe coding" anywhere in this module (that phrase belongs to
      M07 only)
- [x] The rtk/Caveman economics finding states both the advertised (60-90%) and measured
      (~8.5%, and a cost increase for rtk) figures, matching the fact-discipline table in the
      course `CLAUDE.md` exactly
- [x] Lab validation script: `lab/run.sh`, real 3-run stopping-condition test, real pass
- [x] Course slide voiceover script: `planning/voiceover/m12-slide-voiceover.md`
- [x] No diagram excalidraw render pass, hand-drawn SVGs are the deliverable, matching the
      decision already made and recorded in M01's README
