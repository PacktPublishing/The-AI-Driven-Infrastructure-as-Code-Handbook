# M09: Verifying AI-Generated Infrastructure

**Type:** hands-on · **Build order:** lab first · **Duration:** ~60 min ·
**Lab tier:** 1 · **Book chapter:** 9 · **Autonomy step introduced:** step 4, now with a full pipeline

Same code, two scanners, two different answers, and that is not a bug in either tool. This
module builds the rest of the pipeline from M01's thesis, "the agent proposes, the pipeline
decides": scan with Trivy and Checkov, write the org-specific policy that neither scanner's
default rule bundle knows with Conftest, run an honest Infracost cost report, then human
approval, then apply. The threshold that turns that cost report into a gate is M12's.

## What's in this module

```
modules/module-09-verifying-ai-infra/
  README.md               this file, delivery guide
  LAB.md                  Project 09: Build a Scan-and-Policy Pipeline for a Real S3 Module (Tier 1, ~20 min)
  lab/
    module/               the baseline infra: 2 unhardened S3 buckets against Floci
    solution/             hardened version, inline checkov waivers with their reasons
    policy/
      required_tags.rego  the org rule neither scanner's default rule bundle checks
    eval/
      rubric.py           deterministic tagging rubric, graded against an agent's own output
      test_rubric.py      the rubric's own unit tests
      fixture-*.tf        seeded inputs: bad, comment-only, good, and the live agent capture
    pipeline.sh           the assembled 5-stage pipeline: fmt/validate, trivy, checkov, conftest, infracost
    run.sh                validates the whole lab end to end
  reading/
    concepts.md           ~15 min standalone read, the module's explanatory spine
    reference.md          one-page A4 cheat sheet
    diagrams/             7 hand-drawn SVGs, one per section of concepts.md
  explainer/
    sim/
      pipeline-gate-sim.html  interactive 5-stage pipeline walkthrough
  QUIZ.md                 7 questions, collapsible answers
  PROJECTS.md             5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 60 minutes with a break. Each step walks one or two sections of
`reading/concepts.md` with its diagram from `reading/diagrams/` on screen:

1. "The Opening Demo" and "Why They Disagree" (`opening-demo.svg`, `rule-set-overlap.svg`):
   the real Trivy 7 vs Checkov 25 result and why the counts differ, ~10 min.
2. "What Neither Default Rule Bundle Catches" (`opa-gap.svg`): the Owner-tag rule and the
   Conftest gate, ~6 min.
3. "A Cost Check, Wired Honestly" (`cost-gate.svg`): report versus gate, ~3 min.
4. "Order Matters" (`pipeline-order.svg`), then demo `explainer/sim/pipeline-gate-sim.html`
   live, ~5 min.
5. "The Assembled Pipeline" and "What Tier 1 Still Cannot Show You"
   (`pipeline-assembled.svg`, `whats-missing.svg`), ~5 min.
6. Break, then run `LAB.md` live, ~20 min. Real Trivy and Checkov, a real Conftest policy
   that fails then passes, an honest cost-report skip or a real Infracost run, one assembled
   `pipeline.sh`, and the eval rubric run against a live agent capture.
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

The opening-demo counts, Trivy 7 and Checkov 25, were recorded on the scanner versions this
course pins (Trivy 0.72.0, Checkov 3.3.16). `run.sh` asserts those exact counts only on those
versions. On any other version it prints a `WARN` line naming the drift and asserts the lower
bounds the lesson depends on instead: at least one Trivy HIGH/CRITICAL finding, and more
Checkov failures than Trivy findings. To check a newer pair of versions against the recorded
counts, set `M09_TRIVY_PINNED` and `M09_CHECKOV_PINNED` to the versions you have installed.

## Autonomy ladder

Step 4, gated apply, same step M06 introduced, now with the full real pipeline behind the
gate instead of one hook. Scan, policy, and cost all have to pass before a human ever sees
the plan, and the human step still has to say yes.

## Definition-of-done status

- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and is the chapter's spine
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current (`tfsec` never mentioned, Trivy used instead)
- [x] The opening demo's numbers match `labs/shared/floci-spike/RESULTS.md` exactly (Trivy 7,
      Checkov 25) on the pinned scanner versions, reproduced live in this module's own lab
      against the same spike module, not just cited
- [x] Cost is taught as the difference between a report and a gate: `pipeline.sh` runs a
      real Infracost report when a key is configured, skips with a clear message when it
      isn't, never fabricates a number, and fails only if the Infracost CLI itself errors.
      The threshold gate that fails a pipeline past a real figure is built in M12
- [x] Pipeline order in every diagram and in `pipeline.sh` matches the course's pipeline:
      fmt/validate, scan, policy, cost, human approval, apply
- [x] The OPA/Conftest policy in the lab (`required_tags.rego`) encodes a rule confirmed, by
      running both scanners for real, that neither scanner's default rule bundle checks
- [x] Diagrams: 7 hand-drawn SVGs in `reading/diagrams/`, same visual contract as
      M01/M03/M04/M06
- [x] Simulator: `explainer/sim/pipeline-gate-sim.html`, all 8 real interaction states
      (all-pass, 6 individual stage failures, reset) verified via Playwright, zero JS errors
- [x] Eval rubric: `lab/eval/rubric.py` with its own unit tests, graded against a real agent
      capture in `lab/eval/fixture-live.tf`
- [x] Lab validation script: `lab/run.sh`, checks the full real pipeline sequence end to end

## Delivery guide: Udemy

This module's lecture cut mirrors M01/M03/M04/M06's pattern: one concept per lecture, 3-6
minutes each, following the eight sections of `reading/concepts.md`. `LAB.md` ships as a
standalone hands-on lecture after the concept lectures. `QUIZ.md` publishes as the module's
Udemy quiz. `PROJECTS.md` publishes as downloadable resources. The pipeline-gate simulator
ships as an embedded interactive alongside the lesson page.
