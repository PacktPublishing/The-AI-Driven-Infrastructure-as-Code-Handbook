# M01: From ClickOps to Agents

**Type:** conceptual · **Build order:** explainers first · **Duration:** ~50 min ·
**Lab tier:** 0 · **Book chapter:** 1 · **Autonomy step introduced:** the whole ladder,
steps 1-6

The on-ramp. No tooling, no installs, no accounts. Sets every frame the rest of the course
reuses: the seven eras, the agent-as-loop definition, the autonomy ladder, the three-layer
diagnostic, and the thesis, *the agent proposes, the pipeline decides*.

## What's in this module

```
modules/module-01-clickops-to-agents/
  README.md               this file, delivery guide
  explainer/
    sim/
      agent-classifier-sim.html   interactive "is this an agent?" classifier
  LAB.md                   Project 01: Build an Nginx Module Using Terraform and Checkov (Tier 0, ~12 min)
  lab/
    starter/main.tf         the skeleton learners copy, deliberately fails checkov
    solution/main.tf        the fixed version
    run.sh                   checks starter fails checkov and solution passes
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, the spine of Chapter 1 of the book
    reference.md              one-page A4 cheat sheet
    diagrams/                13 hand-drawn SVGs, one per section of concepts.md
  QUIZ.md                  8 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 50 minutes with a break. Each step walks one or two sections of
`reading/concepts.md` with its diagram from `reading/diagrams/` on screen:

1. "How Infrastructure Automation Evolved" (`broken-server.svg`, `seven-eras-staircase.svg`),
   the history, ~17 min.
2. "What Is an Agent?" (`agent-loop.svg`, `three-things-ai.svg`, `coding-agent.svg`,
   `operational-agent.svg`) and "The Autonomy Ladder" (`autonomy-ladder.svg`), the
   definitions, ~14 min. Pause at "Try it: is this an agent?" for the scenario check
   (autocomplete vs. automation vs. agent); `explainer/sim/agent-classifier-sim.html` runs
   it interactively.
3. "Where the AI Infrastructure Industry Actually Stands" (`industry-stats.svg`) and "Why
   Infrastructure Is Harder Than Application Code" (`four-asymmetries.svg`,
   `vulnerability-density.svg`), the honest state of things, ~11 min. Say the vendor
   survey and preprint caveats out loud, every time, they're part of the material, not a
   disclaimer.
4. "The Core Rule" (`thesis-boundary.svg`), "Context, Harness, Loop" (`three-layers.svg`)
   and "What You Will Build" (`journey-map.svg`), ~10 min.
5. Break, then run `LAB.md` live, ~12 min, everyone on their own machine, `terraform` and
   `checkov` only, no agent yet, no cloud account.
6. Close on the Lab's Exercise: three lines on which steps they'd hand to a machine. Collect
   a few out loud if the group is small enough, this primes M02.

`QUIZ.md` and `PROJECTS.md` are take-home, not workshop time, unless you're running a
longer format.

## Delivery guide: Udemy

Thirteen lectures, all inside the 3-6 minute band, one concept per lecture:

| # | Lecture | Section of `reading/concepts.md` | min |
|---|---|---|---|
| 1 | What this course is, and who it's for | chapter opening | 3 |
| 2 | The server nobody can rebuild | "The server nobody can rebuild" | 4 |
| 3 | Seven eras of infrastructure automation | "Seven eras, one pattern" | 5 |
| 4 | What each era solved, and what it left behind | "What each era fixed, and what it left behind" | 5 |
| 5 | The two arrows: intent up, verification up | "Two things keep rising" | 4 |
| 6 | What an agent actually is | "A working definition", "The stopping condition problem" | 4 |
| 7 | Autocomplete, automation, agent | "Three things people call AI", "Coding agents and operational agents" | 4 |
| 8 | The autonomy ladder | "The Autonomy Ladder for Infrastructure Agents" | 4 |
| 9 | Every step needs a gate | "Every step needs a gate" | 4 |
| 10 | Where the industry really is in 2026 | "Where the AI Infrastructure Industry Actually Stands" | 4 |
| 11 | Why infrastructure is harder than app code | "Four differences" | 4 |
| 12 | The evidence nobody wants to hear | "The uncomfortable evidence" | 5 |
| 13 | Propose, don't decide, and your journey from here | "The Core Rule", "Context, Harness, Loop", "What You Will Build" | 6 |

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

- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root
      `LAB.md`, `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 0, no destroy step needed
      because the lab never applies (stated explicitly in the lab)
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as the draft of
      Chapter 1 of the book
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 8 questions, collapsible answers, 5 of 8 scenario-based
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] Lectures cut 3-6 min in the Udemy table above
- [x] Autonomy-ladder step named (step 2, in the lab)
- [x] No retired tools presented as current
- [x] No "prompt engineering," no "vibe coding" as a practice, anywhere in this module
- [x] Every statistic follows the course's fact discipline: source, date and sample size
      stated, and a second source behind every vendor or preprint figure
- [x] Diagrams: 13 hand-drawn SVGs in `reading/diagrams/` cover every section; a separate
      `.excalidraw` render pass was decided against, the SVGs are the deliverable (2026-08-31)
- [x] Lab validation script: `lab/run.sh`, checks starter fails checkov / solution passes
