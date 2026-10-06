# M04: Agent Skills for IaC

**Type:** hands-on · **Build order:** lab first · **Duration:** ~75 min ·
**Lab tier:** 1 · **Book chapter:** 4 · **Autonomy step introduced:** step 3 (propose with plan)

Standing capability, loaded only when a task calls for it. Where M03 gave the agent
context it always has, this module gives it a skill it reaches for on its own, and draws
the line between a skill (voluntary) and a harness gate (enforced), the seam M06 and M08
pick up next.

Spec: [`specs/M04-spec.md`](../../specs/M04-spec.md). Read it before changing anything
here.

## What's in this module

```
modules/module-04-agent-skills/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           8 diagram beats, narrator notes, timing
    deck/
      build_deck.py         generator, mirrors M01/M03's own generator
      m04-agent-skills.html  15-slide self-contained deck
      m04-sequence.md        slide table, fragment map, coverage check
    diagrams/               7 hand-drawn SVGs (title slide has its own inline SVG)
  LAB.md                   Project 04: Build a Terraform VPC Module Using a Claude Code Skill (Tier 1, ~40 min, 2 stages)
  lab/
    .claude/skills/terraform-module-conventions/SKILL.md    Part I's skill, pure prose
    .claude/skills/vpc-environment-scaffold/
      SKILL.md               Part II's skill: design rules in prose + a bundled script
      scripts/check_cidr_overlap.py   real deterministic CIDR-overlap checker
    starter/                Part I run 1, no skill, fails checkov secrets scan
    solution/                Part I run 2, with skill, secrets-clean, applies + destroys on Floci
    vpc/
      modules/vpc/            shared module: VPC, subnets, IGW, NAT (single or per-AZ)
      envs/dev/                1 AZ, single NAT gateway
      envs/staging/            2 AZs, single NAT gateway
      envs/prod/                3 AZs, one NAT gateway per AZ
    run.sh                   validates both parts: runs/tags/pin, overlap checker (clean +
                              seeded collision), and two real floci apply/destroy cycles
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/04-agent-skills.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  9 questions, collapsible answers
  PROJECTS.md              4 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 75 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1-3 (the boundary, anatomy of a `SKILL.md`), ~7 min.
2. Walk beats 4-5 (discoverability, house convention), ~6 min.
3. Walk beats 6-7 (skill vs harness, still step 3), ~7 min. The skill-vs-harness slide is
   the one to slow down on, it's a distinction M06/M08 assume the learner already has.
4. Walk the new "skill ships code" beat (prose vs a bundled script), ~5 min.
5. Break, then run `LAB.md` Part I live, ~15 min. Docker socket mounted, Floci pinned, real
   apply and destroy of a single S3 bucket.
6. Run `LAB.md` Part II live, ~20 min: the multi-environment VPC module, the bundled CIDR
   overlap checker catching a real seeded collision, then a real apply/destroy of the dev
   environment's 12 resources against Floci.
7. Close on Part II's "What each layer actually caught" section, judgment vs arithmetic.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless running a longer
format.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-04-agent-skills/lab
./run.sh
```

Requires `terraform`, `checkov` (pin `3.3.16`, matching Environment Setup; if it's not
on `PATH`, install into a scratch venv first), and Docker reachable at
`/var/run/docker.sock`. It pulls and runs `floci/floci:1.7.0` twice, once per part. Expect,
Part I: run 1 (no skill) fails the checkov secrets scan on `CKV_SECRET_2`, run 2 (with the
skill) is clean and carries the required tags and provider pin, apply/destroy completes
cleanly. Expect, Part II: `dev`/`staging`/`prod` all `terraform validate` clean, the bundled
overlap checker passes on the real environments and correctly catches a seeded CIDR
collision in a scratch copy, and the dev environment's 12 resources (VPC, IGW, NAT gateway,
EIP, 2 subnets, 2 route tables, associations, routes) apply and destroy cleanly.

## Autonomy ladder

Step 3, propose with plan. The skill changes what the agent proposes, not who reads the
plan before `apply` runs, that stays a human, every time, same as step 2.

## Definition-of-done status

- [x] `specs/M04-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root
      `LAB.md`, `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 1, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/04-agent-skills.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 9 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 4 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] No "prompt engineering" used as the umbrella term anywhere in this module
- [x] Lab's generated module is real, applied and destroyed against Floci, not a mock
- [x] `demos/m1-agent-preview` is referenced (read-first step in the lab), not duplicated
- [x] Skill vs harness distinction is stated precisely; harness itself is not taught here
- [x] Autonomy step 3 is named explicitly
- [x] Part II's skill bundles a real deterministic script (`check_cidr_overlap.py`), not
      prose alone, catching a genuine seeded CIDR collision, not a staged one
- [x] Part II's three VPC environments are materially different (AZ count AND NAT
      strategy), not a tfvars copy with one value changed
- [x] Diagram beats: 7 hand-drawn SVGs in `explainer/diagrams/`, same visual contract as
      M01/M03
- [x] Deck: self-contained slides, zero external refs, real Playwright render check,
      no invisible-line regressions
- [x] Course slide voiceover script: `planning/voiceover/m04-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, checks both parts: runs, tags, provider pin,
      the overlap checker (clean and seeded-collision), and two real Floci apply/destroy
      cycles

## Delivery guide: Udemy

This module's lecture cut mirrors M01/M03's pattern: one concept per lecture, 3-6 minutes
each, following the deck's 8 sections. `LAB.md` ships as a standalone hands-on lecture
after the concept lectures. `QUIZ.md` publishes as the module's Udemy quiz. `PROJECTS.md`
publishes as downloadable resources.
