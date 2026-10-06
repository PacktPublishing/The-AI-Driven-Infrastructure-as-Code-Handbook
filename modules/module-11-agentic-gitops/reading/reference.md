# M11 Reference Card: Safe Agentic Delivery to Production

## The full loop, in order

1. Agent proposes → opens a pull request
2. CI pipeline gates it → automatic (fmt, validate, scan, policy)
3. Human reviews and merges → the one manual step
4. Controller reconciles → automatic, unattended, ongoing

## GitOps, in one sentence

The repo is the source of truth. A controller keeps the cluster matching it. Nobody runs
`kubectl apply` by hand.

## Synced vs healthy

| | Healthy | Degraded |
|---|---|---|
| **Synced** | the good state | matches, but broken (the trap) |
| **Out of sync** | still reconciling | worst case |

Watch both. Matching the repo says nothing about whether the thing actually works.

## Step 5, precisely

**Automatic:** every gate in the pipeline, the sync after merge, self-heal on drift.
**Manual:** reading the pull request and deciding to merge it. That's the whole list.

## GitHub Actions skeleton used in this module

```yaml
on:
  pull_request:
    paths:
      - 'path/to/this/module/**'
jobs:
  gate:
    steps:
      - uses: actions/checkout@v4
      - run: terraform fmt -check -diff
      - run: terraform validate
      - uses: bridgecrewio/checkov-action@v12
```

## Argo CD Application skeleton used in this module

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  source:
    repoURL: <your repo>
    path: <path in repo>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

`automated.selfHeal: true` is what makes drift correction unattended, not just synced-on-demand.

## What this module doesn't close

Rollback (getting back to known-good after a bad merge) and incident response (who gets
paged when reconciliation itself fails). Both real, both out of scope here.
