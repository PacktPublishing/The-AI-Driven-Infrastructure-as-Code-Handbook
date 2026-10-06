# M11: Safe Agentic Delivery to Production

**Type:** hands-on · **Build order:** lab first · **Duration:** ~60 min ·
**Lab tier:** 2 · **Book chapter:** 11 · **Autonomy step introduced:** step 5, supervised
autonomy, demonstrated for real for the first time

This module isn't really about GitOps, that's the easy part. It's about the chain that
makes an agent's production change safe to ship without a human reading every line: an
agent proposes a change as a real pull request, a real CI pipeline (Trivy, Checkov, the
same sequence M09 uses) reviews it automatically and catches what the agent missed, a second agent
fixes the real cause from the real CI failure, a human reads one outcome and merges, and a
real GitOps controller, Argo CD, applies the result unattended and correctly. GitOps is
the last link in that chain, not the whole subject.

Spec: [`specs/M11-spec.md`](../../specs/M11-spec.md). Read it before changing anything here.

## What's in this module

```
modules/module-11-agentic-gitops/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md            7 diagram beats, narrator notes, timing
    deck/
      build_deck.py          generator, load_diagram fix upgraded to re.search (see m11-sequence.md)
      m11-agentic-gitops.html   13-slide self-contained deck
      m11-sequence.md         slide table, fragment map, coverage check, a real bug fixed mid-build
    diagrams/                6 hand-drawn SVGs
  LAB.md                   Project 11: Ship an Agent's Change to Production Using a
                           Pipeline and GitOps (Tier 2, ~25 min)
  lab/
    starter/
      kind-config.yaml       cluster config, node image pinned by digest
    pipeline-demo/
      main.tf                 the CI-gated snippet, real post-merge fix in place
    gitops-demo/
      configmap.yaml           what Argo CD actually reconciles
    solution/
      argocd-app.yaml          the real Application pointed at this repo
    run.sh                   real cluster up -> argo cd install -> app sync/healthy ->
                             self-heal check -> numbered teardown
    .gitignore
  reading/
    concepts.md              ~15 min standalone read, also book/chapters/11-agentic-gitops.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  9 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Real evidence behind this module, not simulated

- **A real agent opened the PR, not the course author.** `claude -p ... --permission-mode
  acceptEdits --allowedTools "Read,Edit,Bash(git *),Bash(gh *)"` added a variable with a
  hardcoded AWS-style key, committed, pushed, and ran `gh pr create` itself: real PR #1 on the book's own
  companion repository. Its own output flagged the mistake in passing without stopping
  itself, real evidence that a disclaimer isn't a gate.
- **A real pipeline caught it.** Trivy (added this pass, matching M09's real pipeline,
  0 findings on this toy module, honestly reported as such) and Checkov ran in a
  real GitHub Actions run and failed for a real reason, `CKV_SECRET_2`.
- **A second, separate agent fixed the real cause**, prompted with the real CI failure text
  plus the pre-diagnosed cause and prescribed fix.
- **A real human merge**, `gh pr merge 4 --squash --delete-branch`, the one manual step.
- A real Argo CD install (`argoproj/argo-cd` stable manifests, server-side apply) on a real
  `kind` cluster, pointed at the real, now-merged `lab/gitops-demo/` path in this same repo.
- Real `Synced`/`Healthy` state, real composed `ConfigMap` data.
- A real self-heal test: the `ConfigMap` was patched directly, and the controller corrected
  it back on its own within seconds, no command run to trigger the correction.
- A real numbered teardown, confirmed via `docker ps -a` that no orphan container remained.
- **A real bug found and fixed while building this**: `aquasecurity/trivy-action@0.28.0`
  doesn't resolve, the tag needs a `v` prefix (`@v0.36.0`). Caught from the real CI run's
  own error, not assumed. **A second real bug**: `kind create cluster` changes the shared
  kubeconfig's current-context globally, so a concurrently running cluster (from another
  module, another terminal) silently steals `kubectl`'s target. Fixed by pinning
  `--context kind-m11-lab` (`kind-m11-lab-verify` in `run.sh`) on every `kubectl` call
  after cluster creation, in both `LAB.md` and `run.sh`.

`lab/run.sh` re-verifies the repeatable parts of this sequence (cluster up through teardown)
on every run; the PR/merge sequence happened once, for real, and its result is what
`lab/pipeline-demo/main.tf` and `lab/gitops-demo/configmap.yaml` now show.

## Delivery guide: live workshop

Run in this order, roughly 60 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats 1-2 (hand-run vs CI-run), ~5 min.
2. Walk beats 3-4 (GitOps in one picture, synced vs healthy), ~6 min.
3. Walk beats 5-6 (the full loop traced, step 5 precisely), ~5 min.
4. Walk beat 7 (open edges, named honestly), ~4 min.
5. Walk the lab bridge, ~2 min.
6. Break, then run `LAB.md` live, ~25 min. An agent opens the real PR, real CI catches its
   real flaw, a second agent fixes it, real merge, real Argo CD sync, real self-heal,
   numbered teardown.
7. Close on the lab's Exercise (manual sync policy) if time allows.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-11-agentic-gitops/lab
./run.sh
```

Requires `kind`, `kubectl`, `helm`, `docker`, and `gh` reachable. It creates a real `kind`
cluster pinned by digest, installs Argo CD from its real upstream manifest, points it at
this repo's own merged `gitops-demo/` directory, waits for `Synced`/`Healthy`, tampers with
the composed `ConfigMap` directly and confirms the controller self-heals it, then removes
the Application and deletes the cluster, confirming no orphan container remains. The
one-time PR/CI/merge sequence already happened for real and isn't re-run by this script;
it verifies the file evidence that sequence left behind instead.

## Autonomy ladder

Step 5, supervised autonomy, demonstrated for real for the first time in this course. The
CI pipeline runs multiple gate stages on its own. The GitOps controller reconciles and
self-heals on its own, continuously, well past the moment of any single merge. The one
thing a human still does by hand is read the pull request and decide to merge it. Step 6,
unattended, would mean removing even that step; this module names the gap honestly and
does not build it.

## Definition-of-done status

- [x] `specs/M11-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 2, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/11-agentic-gitops.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 9 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current
- [x] The lab's CI workflow is real and caught a real flaw an agent introduced on its own,
      automatically: PR #1 on the book's companion repo, opened by `claude -p` itself,
      `CKV_SECRET_2`, fixed by a second real agent session, then merged for real
- [x] GitOps reconciliation demonstrated for real against a real `kind` cluster, including a
      real self-heal test, not described only in prose
- [x] Step 5 named precisely, with exactly what remains manual (the merge) stated clearly
- [x] The lab's teardown is a numbered step (remove Application, delete cluster), not a
      footnote
- [x] Diagram beats: 6 hand-drawn SVGs in `explainer/diagrams/`, same visual contract as
      M01/M03/M04/M06/M09/M10
- [x] Deck: 13 self-contained slides (title/closing re-worded for the reframe, same 11
      content slides). `_looks_like_title` upgraded to the strict exact-match-or-similarity
      version (was still the loose substring-containment version that caused the M03
      "REDUCE" regression, until this pass). Verified with a real static parse of the
      built HTML: 13 sections, zero duplicate title-in-SVG hits, old title string gone.
      Playwright wasn't available in this environment this pass, so no fresh headless
      screenshot was taken; the static parse is the honest substitute, not a Playwright
      substitute claimed as one.
- [x] Course slide voiceover script: `planning/voiceover/m11-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, real cluster-up-to-teardown sequence, ran and
      passed

## Delivery guide: Udemy

One concept per lecture, 3-6 minutes each, following the deck's sections. `LAB.md` ships as
a standalone hands-on lecture after the concept lectures, note in the lecture description
that this lab needs `kind`/`kubectl`/`helm`/Docker/`gh` locally, no cloud account, and that
the PR/merge portion is demonstrated against this course's own public labs repo. `QUIZ.md`
publishes as the module's Udemy quiz. `PROJECTS.md` publishes as downloadable resources.
