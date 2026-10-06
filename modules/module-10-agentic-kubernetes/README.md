# M10: Agentic Kubernetes and Platform IaC

**Type:** hands-on · **Build order:** lab first · **Duration:** ~60 min ·
**Lab tier:** 2 · **Book chapter:** 10 · **Autonomy step introduced:** none new, step 3/4
applied to a new substrate

Every module before this ran against Terraform, local providers or Floci-emulated cloud.
This module keeps the discipline and moves it onto a real substrate: a real `kind` cluster,
real Helm 4, and Crossplane v2 turning a namespaced custom resource into real,
cluster-managed infrastructure. Tier 2 starts here, still free, no cloud account.

The module's real build is a database-as-a-service capability, delivered three ways: raw
manifests, a Helm chart, and a namespaced Crossplane XR, plus an agent proposing a real
request against the XR's schema. No Backstage, no catalog product, this stays at the level a
platform team actually operates: charts, manifests, and Kubernetes-native custom resources.

Spec: [`specs/M10-spec.md`](../../specs/M10-spec.md). Read it before changing anything here.

## What's in this module

```
modules/module-10-agentic-kubernetes/
  README.md               this file, delivery guide
  explainer/
    EXPLAINER.md            diagram beats, narrator notes, timing
    deck/
      build_deck.py          generator, strict title-match fix carried forward from M03/M06
      m10-agentic-kubernetes.html   16-slide self-contained deck
      m10-sequence.md         slide table, fragment map, coverage check
    diagrams/                8 hand-drawn SVGs (title/closing slides have their own inline SVG)
  LAB.md                   Project 10: Build a Database-as-a-Service Capability Using Helm,
                           Manifests, and Crossplane v2 (Tier 2, ~45 min)
  lab/
    starter/
      kind-config.yaml       cluster config, node image pinned by digest
    manifests/                layer 1: raw Postgres Secret, Service, StatefulSet, by hand
    charts/postgres-db/       layer 2: the same Postgres, packaged as a Helm chart
    solution/
      xrd.yaml, composition.yaml, xr.yaml          warm-up: namespaced XAppConfig, no claim
      db-xrd.yaml, db-composition.yaml, db-xr.yaml  layer 3: namespaced XDatabase
      db-composer-rbac.yaml   the real RBAC grant a native-kind Composition needs
    requests/                 where the agent-proposed XR lands, gitignored, generated live
    run.sh                   real cluster up -> crossplane v2 -> warm-up XR -> layer 1/2/3 ->
                             teardown, all nine steps real, no fixed sleeps
    .gitignore
  reading/
    concepts.md              ~18 min standalone read, also book/chapters/10-agentic-kubernetes.md
    reference.md              one-page A4 cheat sheet
  QUIZ.md                  9 questions, collapsible answers
  PROJECTS.md              5 stretch project seeds
```

## Delivery guide: live workshop

Run in this order, roughly 60 minutes with a break:

1. Walk `explainer/EXPLAINER.md` beats on plan/apply vs reconcile and a real cluster in a
   container, ~5 min.
2. Walk the Helm 4 and Crossplane v2 beats, ~6 min.
3. Walk the XRD/Composition/XR beat mapped to Terraform, ~5 min.
4. Walk the authority-boundary beat, redrawn for `kubectl diff`, ~4 min.
5. Walk the new "one capability, three ways" and "composed-resource RBAC" beats, ~6 min.
6. Walk the lab bridge, ~2 min.
7. Break, then run `LAB.md` live, ~40-45 min. Real `kind` cluster, real Crossplane v2 install,
   a real Postgres delivered three ways, a real agent proposing a second database request,
   numbered teardown.
8. Close on the lab's Exercise if time allows.

## Running the lab yourself first

Before you deliver this module, run the lab's real check once:

```
cd modules/module-10-agentic-kubernetes/lab
./run.sh
```

Requires `kind`, `kubectl`, `helm`, and Docker reachable. It creates a real `kind` cluster
pinned by digest, installs Crossplane v2.4.0 via its real Helm chart, runs the warm-up
`XAppConfig` XR, then builds the same Postgres database three ways: raw manifests applied
directly, the same Postgres packaged as a Helm chart and installed as a second instance, and a
namespaced `XDatabase` XR composing a real `StatefulSet`, `Service`, and `Secret` (including
the RBAC grant that composing a native `StatefulSet` needs). It verifies each layer with a
real query against the running Postgres, not a status field. Deletes everything, confirms
garbage collection via owner references, then deletes the cluster and confirms no orphan
container remains. Takes 8-10 minutes end to end, most of it Crossplane's image pull and the
function pod's own health check.

## Autonomy ladder

No new step. Step 3 (propose with plan) and step 4 (gated apply) both apply here exactly as
they did against Terraform, just against `kubectl diff` and `kubectl apply` instead. The
substrate changed, the authority boundary from M01 did not.

## Definition-of-done status

- [x] `specs/M10-spec.md` read before building
- [x] All module directories present (`explainer/`, `lab/`, `reading/`, plus root `LAB.md`,
      `QUIZ.md`, `PROJECTS.md`, `README.md`)
- [x] `EXPLAINER.md` has narrator notes and timing for every diagram beat
- [x] `LAB.md` steps are copy-pasteable, solo-completable, Tier 2, real captured output only
- [x] `reading/concepts.md` is standalone-readable (~15 min) and doubles as
      `book/chapters/10-agentic-kubernetes.md`
- [x] `reading/reference.md` is a one-side-of-A4 cheat sheet
- [x] `QUIZ.md`: 9 questions, collapsible answers, scenario-heavy
- [x] `PROJECTS.md`: 5 stretch projects, hints not solutions
- [x] `README.md` (this file), live + Udemy delivery guide
- [x] No retired tools presented as current, no Backstage or platform-catalog framing
- [x] `kind` cluster config pins the node image by digest, not `latest` or a bare tag,
      confirmed against a real `docker pull` digest
- [x] Crossplane v2's namespaced-XR change stated precisely: claims removed, not "claims are
      now optional"
- [x] The lab's teardown is a numbered step, not a footnote, covers both XRs and the Helm
      release
- [x] Helm 4 used throughout, no Helm 3 command shown as current
- [x] Diagram beats: 8 hand-drawn SVGs in `explainer/diagrams/`, same visual contract as
      M01/M03/M04/M06/M09
- [x] Deck: 16 self-contained slides, zero external refs, strict title-match fix (exact match
      or fuzzy ratio > 0.75, no substring containment) carried forward from M03
- [x] Course slide voiceover script: `planning/voiceover/m10-slide-voiceover.md`
- [x] Lab validation script: `lab/run.sh`, real cluster-up-to-teardown sequence across all
      three delivery layers, ran and passed
- [x] A database delivered three real ways (manifests, Helm chart, Crossplane XR), verified
      by an actual query against each running Postgres instance, not a status field
- [x] A real agent (Claude Code, `--allowedTools Read,Write`, no `Bash`) proposes a second
      database request from the XRD's schema alone; a human reads the diff and applies it

## Delivery guide: Udemy

One concept per lecture, 3-6 minutes each, following the deck's sections. `LAB.md` ships as a
standalone hands-on lecture after the concept lectures, note in the lecture description that
this lab needs `kind`/`kubectl`/`helm`/Docker locally, no cloud account. `QUIZ.md` publishes as
the module's Udemy quiz. `PROJECTS.md` publishes as downloadable resources.
