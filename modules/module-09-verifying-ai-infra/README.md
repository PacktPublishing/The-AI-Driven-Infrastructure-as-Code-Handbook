# M09: Verifying AI-Generated Infrastructure

**Type:** hands-on · **Build order:** lab first · **Duration:** ~60 min ·
**Lab tier:** 1 · **Book chapter:** 9 · **Autonomy step introduced:** step 4, now with a full pipeline

Same code, two scanners, two different answers, and that is not a bug in either tool. This
module builds the rest of the pipeline from M01's thesis, "the agent proposes, the pipeline
decides": scan with Trivy and Checkov, write the org-specific policy neither one knows with
Conftest, treat cost as a real gate with Infracost, then human approval, then apply.

Spec: [`specs/M09-spec.md`](../../specs/M09-spec.md). Read it before changing anything here.

## What's in this module

```
modules/module-09-verifying-ai-infra/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           8 diagram beats, narrator notes, timing
    deck/
      build_deck.py         generator, mirrors M01/M03/M04/M06's own generator
      m09-verifying-ai-infra.html   16-slide self-contained deck
      m09-sequence.md        slide table, fragment map, coverage check
    diagrams/               7 hand-drawn SVGs (title slide has its own inline SVG)
    sim/
      pipeline-gate-sim.html interactive 5-stage pipeline walkthrough
  LAB.md                   Project 09: Build a Scan-and-Policy Pipeline for a Real S3 Module (Tier 1, ~20 min)
  lab/
    module/                 the baseline infra: 2 unhardened S3 buckets against Floci
    solution/                hardened version, real trivy/checkov ignores with reasons
    policy/
      required_tags.rego     the org rule neither trivy nor checkov can check
    pipeline.sh              the assembled 5-stage pipeline, real fmt/trivy/checkov/conftest/infracost
    run.sh                   validates starter blocks, solution passes, end to end
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/09-verifying-ai-infra.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  7 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 60 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1-2 (the opening demo, real Trivy 7 vs Checkov 25), ~4 min.
2. Walk beats 3-4 (why they disagree, the OPA/Conftest gap), ~6 min.
3. Walk beat 5 (cost as a gate), ~3 min.
4. Walk beat 6, demo the pipeline-gate sim live, ~5 min.
5. Walk beats 7-8 (the assembled pipeline, honest Tier 1 limits), ~5 min.
6. Break, then run `LAB.md` live, ~20 min. Real Trivy and Checkov, a real Conftest policy
   that fails then passes, an honest cost-gate skip or a real Infracost run, one assembled
   `pipeline.sh`.
7. Close on the lab's summary: every module since M06 has built one more real stage of this.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless running a longer format.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-09-verifying-ai-infra/lab
./run.sh
```

Requires `trivy`, `checkov`, and `conftest` on `PATH`, plus Docker reachable at
`/var/run/docker.sock` for the Floci-backed plan stage. It confirms the starter module fails
at the trivy stage, the solution passes fmt/trivy/checkov/conftest, and honestly skips (or
runs, if `INFRACOST_API_KEY` is set) the cost stage.

## Autonomy ladder

Step 4, gated apply, same step M06 introduced, now with the full real pipeline behind the
gate instead of one hook. Scan, policy, and cost all have to pass before a human ever sees
the plan, and the human step still has to say yes.

## Definition-of-done status

- [x] `specs/M09-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/09-verifying-ai-infra.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current (`tfsec` never mentioned, Trivy used instead)
- [x] The opening demo's numbers match `labs/shared/floci-spike/RESULTS.md` exactly (Trivy 7,
      Checkov 25), reproduced live in this module's own lab against the same spike module,
      not just cited
- [x] Cost is taught and demonstrated as a gate: `pipeline.sh` fails the pipeline past a real
      Infracost threshold when a key is configured, and never fabricates a number when it isn't
- [x] Pipeline order in every diagram and in `pipeline.sh` matches
      `CLAUDE.md`: fmt/validate, scan, policy, cost, human approval, apply
- [x] The OPA/Conftest policy in the lab (`required_tags.rego`) encodes a rule confirmed, by
      running both scanners for real, that neither Trivy nor Checkov checks
- [x] Diagram beats: 7 hand-drawn SVGs in `explainer/diagrams/`, same visual contract as
      M01/M03/M04/M06. Found and fixed a real bug in the shared `load_diagram()` pattern
      (documented in `explainer/deck/m09-sequence.md`) that was silently stripping real
      content labels, not just redundant titles
- [x] Deck: 16 self-contained slides, zero external refs, real Playwright render check across
      every diagram slide and all 6 lab-bridge fragments, zero invisible-line regressions
- [x] Simulator: `pipeline-gate-sim.html`, all 8 real interaction states (all-pass, 6
      individual stage failures, reset) verified via Playwright, zero JS errors
- [x] Course slide voiceover script: `planning/voiceover/m09-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, checks the full real pipeline sequence end to end

## Delivery guide: Udemy

This module's lecture cut mirrors M01/M03/M04/M06's pattern: one concept per lecture, 3-6
minutes each, following the deck's 8 sections. `LAB.md` ships as a standalone hands-on
lecture after the concept lectures. `QUIZ.md` publishes as the module's Udemy quiz.
`PROJECTS.md` publishes as downloadable resources. The pipeline-gate simulator ships as an
embedded interactive alongside the lesson page.
