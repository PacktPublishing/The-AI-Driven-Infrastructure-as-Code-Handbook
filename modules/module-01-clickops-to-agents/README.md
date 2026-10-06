# M01: From ClickOps to Agents

**Type:** conceptual · **Build order:** explainers first · **Duration:** ~50 min ·
**Lab tier:** 0 · **Book chapter:** 1 · **Autonomy step introduced:** the whole ladder,
steps 1-6

The on-ramp. No tooling, no installs, no accounts. Sets every frame the rest of the course
reuses: the seven eras, the agent-as-loop definition, the autonomy ladder, the three-layer
diagnostic, and the thesis, *the agent proposes, the pipeline decides*.

Spec: [`specs/M01-spec.md`](../../specs/M01-spec.md). Read it before changing anything
here.

## What's in this module

```
modules/module-01-clickops-to-agents/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md           16 diagram beats, narrator notes, timing
  LAB.md                   Project 01: Build an Nginx Module Using Terraform and Checkov (Tier 0, ~12 min)
  lab/
    starter/main.tf         the skeleton learners copy, deliberately fails checkov
    solution/main.tf        the fixed version
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/01-clickops-to-agents.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  8 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 50 minutes with a break:

1. Walk beats 1-6 of `explainer/EXPLAINER.md` (history), ~17 min.
2. Walk beats 7-10 (definitions), ~14 min. Pause after beat 8 for the scenario check
   (autocomplete vs. automation vs. agent) built into the narrator notes.
3. Walk beats 11-13 (the honest state of things, the evidence), ~11 min. Say the vendor
   survey and preprint caveats out loud, every time, they're part of the material, not a
   disclaimer.
4. Walk beats 14-16 (thesis, three layers, journey), ~10 min.
5. Break, then run `LAB.md` live, ~12 min, everyone on their own machine, `terraform` and
   `checkov` only, no agent yet, no cloud account.
6. Close on the Lab's Exercise: three lines on which steps they'd hand to a machine. Collect
   a few out loud if the group is small enough, this primes M02.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless you're running a
longer format.

## Delivery guide: Udemy

Thirteen lectures, all inside the 3-6 minute band, one concept per lecture:

| # | Lecture | Beats | min |
|---|---|---|---|
| 1 | What this course is, and who it's for | 1 | 3 |
| 2 | The server nobody can rebuild | 2 | 4 |
| 3 | Seven eras of infrastructure automation | 3 | 5 |
| 4 | What each era solved, and what it left behind | 4, 5 | 5 |
| 5 | The two arrows: intent up, verification up | 6 | 4 |
| 6 | What an agent actually is | 7 | 4 |
| 7 | Autocomplete, automation, agent | 8 | 4 |
| 8 | The autonomy ladder | 9 | 4 |
| 9 | Every step needs a gate | 10 | 4 |
| 10 | Where the industry really is in 2026 | 11 | 4 |
| 11 | Why infrastructure is harder than app code | 12 | 4 |
| 12 | The evidence nobody wants to hear | 13 | 5 |
| 13 | Propose, don't decide, and your journey from here | 14, 15, 16 | 6 |

`LAB.md` ships as a standalone hands-on lecture after lecture 13, since Udemy learners
complete it solo, not in a workshop room. `QUIZ.md` publishes as the module's Udemy quiz.
`PROJECTS.md` publishes as downloadable resources. Prompt for a review once the learner
finishes the quiz, not before.

## Running the lab yourself first

Before you deliver this module, run the lab end to end once, it takes under two minutes:

```
cd modules/module-01-clickops-to-agents/lab/starter
terraform fmt -diff
terraform init -backend=false && terraform validate
terraform plan
checkov -d .
```

`checkov` should exit 1, one finding, `CKV_SECRET_2: "AWS Access Key"`. Then check the fix:

```
cd ../solution
terraform fmt -diff && terraform init -backend=false && terraform validate
checkov -d .
```

`checkov` should exit 0. Docker must be reachable at `/var/run/docker.sock` for `terraform
plan` to resolve the `docker_image` data source, but nothing in this lab ever runs
`terraform apply`, so there's no container left running and no destroy step needed.

## Autonomy ladder

This module introduces the whole ladder (steps 1-6) as a concept, it doesn't put the
learner on any step above 2. The lab has them read and adapt a supplied skeleton, that's
step 2, draft, human reads every line before doing anything with it.

## Definition-of-done status

- [x] `specs/M01-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root
      `LAB.md`, `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 0, no destroy step needed
      because the lab never applies (stated explicitly in the lab)
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/01-clickops-to-agents.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 8 questions, collapsible answers, 5 of 8 scenario-based
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] Lectures cut 3-6 min in the Udemy table above
- [x] Autonomy-ladder step named (step 2, in the lab)
- [x] No retired tools presented as current
- [x] No "prompt engineering," no "vibe coding" as a practice, anywhere in this module
- [x] Every statistic matches the fact-discipline table in the course `CLAUDE.md`
- [x] Diagram beats: hand-drawn SVGs in `explainer/diagrams/` cover every beat; a separate
      `.excalidraw` render pass was decided against, the SVGs are the deliverable (2026-08-31)
- [x] Course slide voiceover script: `planning/voiceover/m01-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, checks starter fails checkov / solution passes
