# M08: Harness Engineering

**Type:** hands-on · **Build order:** lab first · **Duration:** ~55 min ·
**Lab tier:** 1 · **Book chapter:** 8 · **Autonomy step introduced:** none new, still step 4, the
precondition for step 5 (supervised autonomy, M12)

Three pieces, taught separately, become one assembled system. M04 gave the agent a skill, M05 a
live MCP connection, M06 a hook. This module assembles them around one real discipline, the
superpowers pattern: test-first, verify before claiming, root-cause debugging. The course's own
bottom-up rule applies directly: never add a loop on top of a broken harness.

Spec: [`specs/M08-spec.md`](../../specs/M08-spec.md). Read it before changing anything here.

## What's in this module

```
modules/module-08-harness-engineering/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           7 diagram beats, narrator notes, timing
    deck/
      build_deck.py         generator, mirrors M06/M07's own generator
      m08-harness-engineering.html   14-slide self-contained deck
      m08-sequence.md        slide table, fragment map, coverage check
    diagrams/               6 hand-drawn SVGs (title slide has its own inline SVG)
  LAB.md                   Project 08: Build a Verification-Before-Claiming Harness Using a Skill and a Hook (Tier 1, ~20 min)
  lab/
    starter/                 the baseline module: 1 S3 bucket, 7 real checkov findings
    solution/                versioning + public access block fixed, 5 unrelated findings left honest
    hooks/
      verify_claim.sh         the hook: claim-vs-evidence regex check
    .claude/
      skills/verify-before-claiming/SKILL.md   the skill: states the rule
      settings.local.example.json               real Claude Code hook wiring, project-scoped
    evidence/
      unbacked-claim.txt      real transcript, no evidence, hook blocks it
      backed-claim.txt        real transcript, real checkov output, hook passes it
    run.sh                   validates the full real sequence, including a real Floci apply/destroy
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/08-harness-engineering.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  7 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 55 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1-2 (three pieces, one system), ~4 min.
2. Walk beat 3 (the superpowers pattern), ~3 min.
3. Walk beats 4-5 (a claim without evidence, a claim with evidence), demo the real hook live
   against both transcripts, ~6 min.
4. Walk beat 6 (harness vs context, revisited), ~3 min.
5. Walk beat 7 (harness before loop), ~2 min.
6. Break, then run `LAB.md` live, ~20 min. No harness first, then a real skill and a real hook,
   a real blocked claim, a real passed claim, real apply and destroy against Floci.
7. Close on the lab's exercise: write a harness for a discipline the learner's own team skips.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless running a longer format.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-08-harness-engineering/lab
./run.sh
```

Requires `terraform`, `checkov`, and Docker reachable at `/var/run/docker.sock`. It confirms the
starter fails 7 real checkov checks, the solution fixes exactly the 2 targeted ones and honestly
leaves 5 unrelated findings, the verification hook blocks a real unbacked claim and passes a real
backed one, then pulls and runs `floci/floci:1.7.0`, applies the solution for real, and destroys
it.

## Harness mechanism: what's real here

The lab's hook is a standalone shell script (`lab/hooks/verify_claim.sh`), tested directly by
`run.sh` against two real captured transcripts. `lab/.claude/settings.local.example.json` shows
the real Claude Code `Stop` hook wiring a learner would use to run this same check automatically
at the end of every turn, matching the mechanism documented in Claude Code's own hooks system.
This module did not modify any live global Claude Code configuration to build or verify itself,
same caution as M06's permission-boundary example.

## Autonomy ladder

No new step. Still step 4 in practice, but this module is what makes step 5 (supervised autonomy,
taught in M12) safe to attempt: a loop on top of a broken harness just repeats its mistakes faster.

## Definition-of-done status

- [x] `specs/M08-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/08-harness-engineering.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 7 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] The lab's hook is real: it actually blocks an unbacked claim and passes a backed one, real
      captured output both times, not simulated
- [x] All three superpowers disciplines (test-first, verify-before-claiming, root-cause debugging)
      named and explained, not just verification alone
- [x] Harness vs context distinction explicitly ties back to M01's three-layer diagnostic
- [x] No new autonomy step introduced; step 5 previewed as "what this makes possible," not taught
- [x] Diagram beats: 6 hand-drawn SVGs in `explainer/diagrams/`, same visual contract as
      M01/M03/M04/M06/M07
- [x] Deck: 14 self-contained slides, zero external refs, real Playwright render check, zero
      invisible-line regressions, every diagram's real text verified present in the rendered deck
- [x] Course slide voiceover script: `planning/voiceover/m08-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, checks the full real sequence end to end including a
      real Floci apply/destroy
- [x] Zero "rung" anywhere in learner-facing content, "step" used throughout

## Delivery guide: Udemy

This module's lecture cut mirrors the established pattern: one concept per lecture, 3-6 minutes
each, following the deck's 6 sections. `LAB.md` ships as a standalone hands-on lecture after the
concept lectures. `QUIZ.md` publishes as the module's Udemy quiz. `PROJECTS.md` publishes as
downloadable resources.
