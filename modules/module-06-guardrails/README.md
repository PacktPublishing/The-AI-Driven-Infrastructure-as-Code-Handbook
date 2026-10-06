# M06: Guardrails: Permissions, Hooks, Blast Radius

**Type:** hands-on · **Build order:** lab first · **Duration:** ~55 min ·
**Lab tier:** 1 · **Book chapter:** 6 · **Autonomy step introduced:** step 4 (gated apply)

Not what the agent chooses to do, what it cannot avoid. Where M04 gave the agent a skill it
could reach for on its own, this module builds the enforced half: a hook that runs on every
attempted `apply`, and a permission boundary that limits what the agent can touch before a
plan even exists. This is the piece of M01's thesis, "the agent proposes, the pipeline
decides," that actually stops an unsafe apply.

Spec: [`specs/M06-spec.md`](../../specs/M06-spec.md). Read it before changing anything here.

## What's in this module

```
modules/module-06-guardrails/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           8 diagram beats, narrator notes, timing
    deck/
      build_deck.py         generator, mirrors M01/M03/M04's own generator
      m06-guardrails.html    14-slide self-contained deck
      m06-sequence.md        slide table, fragment map, coverage check
    diagrams/               6 hand-drawn SVGs (title slide has its own inline SVG)
    sim/
      blast-radius-sim.html  interactive gate visualizer, real terraform plan -json output
  LAB.md                   Project 06: Guard a Real Delete Using a Hook and a Plan-Approve-Apply Harness (Tier 1, ~40 min)
  lab/
    module/                  the baseline infra: 2 S3 buckets against Floci
    hooks/
      blast_radius_gate.sh    the gate itself: delete / count / high-radius-type checks
      apply_with_gate.sh      wraps plan -> show -json -> gate -> apply
    .claude/settings.local.example.json   the permission-boundary example (deny Write/Edit on shared/**)
    run.sh                   validates the full real sequence against Floci
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/06-guardrails.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  7 questions, collapsible answers
  PROJECTS.md              3 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 55 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1-2 (the checkpoint, the permission boundary), ~4 min.
2. Walk beats 3-4 (voluntary vs enforced, where a hook sits), ~6 min.
3. Walk beat 5 (blast radius mechanics), demo the sim live, ~5 min.
4. Walk beats 6-7 (gate vs warning, step 4), ~6 min.
5. Walk beat 8 (the lab bridge), ~2 min.
6. Break, then run `LAB.md` live, ~20 min. Docker socket mounted, Floci pinned, real apply,
   real blocked delete, real destroy.
7. Close on the lab's "Which failure was which" section.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless running a longer format.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-06-guardrails/lab
./run.sh
```

Requires `terraform`, `jq`, and Docker reachable at `/var/run/docker.sock`. It pulls and runs
`floci/floci:1.7.0`, applies a real baseline, deletes a bucket with no gate (succeeds), restores
it, attempts the identical delete through the gate (blocked, bucket still exists), applies a
safe change through the gate (passes), blocks a high-radius resource type, blocks an oversized
batch, then reconciles and destroys everything.

## Autonomy ladder

Step 4, gated apply. Automated checks (the hook) and human approval, together. A hook passing
does not mean skip the human, and a human approving does not mean the hook is redundant, both
have to say yes.

## Definition-of-done status

- [x] `specs/M06-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/06-guardrails.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 3 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] The lab's hook is real: it actually blocks a real delete against real Floci state, not a
      simulated one
- [x] Skill vs hook distinction stated precisely, does not blur voluntary and enforced together
- [x] Autonomy step 4 named explicitly, shown as checks-plus-approval, not checks-alone
- [x] Simulator's canned plans are realistic `terraform plan -json` output, verified against 9
      real interaction states via Playwright
- [x] Diagram beats: 6 hand-drawn SVGs in `explainer/diagrams/`, same visual contract as
      M01/M03/M04
- [x] Deck: 14 self-contained slides, zero external refs, real Playwright render check across
      all 14 slides and every fragment, zero invisible-line regressions
- [x] Course slide voiceover script: `planning/voiceover/m06-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, checks the full real gate sequence end to end

## Delivery guide: Udemy

This module's lecture cut mirrors M01/M03/M04's pattern: one concept per lecture, 3-6 minutes
each, following the deck's 8 sections. `LAB.md` ships as a standalone hands-on lecture after the
concept lectures. `QUIZ.md` publishes as the module's Udemy quiz. `PROJECTS.md` publishes as
downloadable resources. The blast-radius simulator ships as an embedded interactive alongside
the lesson page.
