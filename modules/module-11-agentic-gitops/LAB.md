# Project 11: Ship an Agent's Change to Production Using a Pipeline and GitOps

**Tier 2** · ~25 min · a real GitHub Actions workflow, a real agent-opened pull request, a real
Argo CD install reconciling a real `kind` cluster. Docker required, same as every earlier
Tier 1/2 lab. Numbered teardown at the end.

In this project, you will wire an automated CI gate onto a real GitHub repo, let an agent open a
real pull request on its own, watch the gate catch a real mistake in that agent's commit, send a
second agent in to fix the real cause, merge the result, then let a real GitOps controller apply
it to a `kind` cluster, unattended.

**What you're building, at a glance:**

- An automated CI gate on GitHub pull requests: fmt, validate, Trivy, Checkov
- A real pull request, opened by an agent, no human touching the diff first
- A real CI failure, caught by the gate, on the agent's own hardcoded secret
- A second agent fixing the real cause, from the CI output alone
- A merge, the one manual step in the whole chain
- A real Argo CD install reconciling a real cluster, including self-healing a manual tamper

GitOps mechanics, stage 4 below, are the easy part of this project, not the point. The point is
what makes an agent's production change safe to ship without a human reading every line: an
automated gate that catches the agent's own mistake, a second agent that fixes the cause once it
sees the gate's output, and a human who reviews one outcome instead of a diff. GitOps applies the
result afterward, unattended and correctly. It's the last link in the chain, not the whole
subject. M10 stood up a cluster and requested a namespaced resource by hand, this project is
where that same cluster starts receiving changes an agent proposed.

## Pre Requisites

- `kind`, `kubectl`, `helm`, `docker`, and `gh` all on `PATH`, and `gh auth status` logged in.
  Check with:

```
kind version
kubectl version --client
helm version
docker info
gh auth status
```

If `docker info` hangs or errors, stop and fix Docker first, same as every earlier lab.

## The intent

> Take the checkov-style gate from M09 and make it run on its own, on every pull request. Once a
> pull request merges, a real controller should reconcile a real cluster to match, with nobody
> running `kubectl apply`.

## Stage 1: Wire the automated gate onto pull requests

`file: .github/workflows/m11-pipeline-demo.yml`
```
name: M11 pipeline demo

on:
  pull_request:
    paths:
      - 'modules/module-11-agentic-gitops/lab/pipeline-demo/**'

jobs:
  gate:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: modules/module-11-agentic-gitops/lab/pipeline-demo
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.8
      - name: terraform fmt
        run: terraform fmt -check -diff
      - name: terraform init
        run: terraform init -backend=false -input=false
      - name: terraform validate
        run: terraform validate
      - name: trivy
        uses: aquasecurity/trivy-action@v0.36.0
        with:
          scan-type: config
          scan-ref: modules/module-11-agentic-gitops/lab/pipeline-demo
          severity: HIGH,CRITICAL
          exit-code: 1
      - name: checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: modules/module-11-agentic-gitops/lab/pipeline-demo
          quiet: true
          compact: true
```

The `paths:` filter matters. Without it, every pull request in the repo would trigger this
workflow, including ones that never touch this module.

This is the same fmt/validate/Trivy/Checkov sequence as M09's `pipeline.sh`, minus the policy
and cost stages, which need a `policy/` directory and an Infracost API key this toy module
doesn't carry. Worth saying plainly: this module's `local_file` resources have nothing
Trivy's cloud/container checks look for, so it runs clean here, 0 findings, every time. That
is not a wasted stage. It is the same command M09 ran against real AWS resources and found 7
HIGH/CRITICAL findings, wired to run automatically now, on infrastructure that happens not to
trip it. Checkov is what actually catches this lab's finding, next.

## Stage 2: Let an agent open the pull request

### Step 1: Ask the agent to make the change and open a PR

Every earlier lab in this course had you drive the agent through each step yourself. This one
is different on purpose: the thing being tested is whether a *pipeline*, not a human proofreading
a diff, catches a mistake the agent makes on its own. So the agent opens this pull request, not
you.

**Ask** Claude Code, from this repo, to make a real, ordinary-sounding change and open a real PR
for it:

```
claude -p "Add a new Terraform variable named signing_key_id to
modules/module-11-agentic-gitops/lab/pipeline-demo/main.tf. Type string, described as 'Key ID
used to sign outbound webhook payloads', default value a fake but realistic AWS access key ID
literal, the way a developer in a hurry might write it. Add a local_file resource named
webhook_signing_config that writes SIGNING_KEY_ID=\${var.signing_key_id} to
\${path.module}/rendered/signing.env, matching the existing pipeline_config resource's pattern.
Commit on the current branch, push, and open a real PR against
schoolofdevops/310-agentic-iac-book with gh pr create." \
  --permission-mode acceptEdits --allowedTools "Read,Edit,Bash(git *),Bash(gh *)"
```

`[ Expected output ]`
```
Done. PR open, CI started.

https://github.com/schoolofdevops/310-agentic-iac-book/pull/1 - commit 1bf991a on
m11-agent-proposed-demo.

terraform fmt -check -diff clean. Checks 0/2 passed, still running: terraform validate
and trivy should pass, checkov should fail CKV_SECRET_2 on that default.

1. Hardcoded credential default is a real smell, shipped on purpose. AKIA3XQ7PZVK9RTLM2WD
   is fabricated, no real credential, but it contradicts webhook_token's own "never a
   default" comment two lines up. I flagged it in the PR body for reviewers.
```

Read that note again. The agent noticed its own mistake on the way out and said so. It went
further than that: it wrote the same warning into the pull request's own description, where a
human reviewer would see it. Then it committed and pushed anyway, because nothing in its
instructions told it to stop. That's exactly the gap a gate closes and a polite disclaimer
doesn't.

### Step 2: Watch the gate catch the mistake

**Ask** the real pull request for its real CI result. Your PR number will differ from the one
below, so use your own:

```
gh pr checks 1
```

`[ Expected output ]`
```
gate	fail	47s	https://github.com/schoolofdevops/310-agentic-iac-book/actions/runs/36970690837/job/110723839988
contract	pass	6s	https://github.com/schoolofdevops/310-agentic-iac-book/actions/runs/36970690886/job/110723840182
```

Two checks ran, not one. `gate` is this module's workflow and it failed. `contract` is the
companion repository's own book-contract gate, unrelated to this module, and it passed. Piped
anywhere other than a terminal, `gh` prints one line per check; run interactively it draws the
same rows as a table, and `--watch` holds the terminal until they finish.

Inside that failing job every earlier step passed: `terraform fmt`, `terraform init`,
`terraform validate`, and `trivy`. Only `checkov` failed. **Ask** the run what it found, using
the run ID from the URL above:

```
gh run view 36970690837 --log-failed
```

`[ Expected output ]`
```
Passed checks: 0, Failed checks: 1, Skipped checks: 0

Check: CKV_SECRET_2: "AWS Access Key"
	FAILED for resource: d2657f785d06fb5f28816341b7d36fb44b3baca1
	File: /main.tf:19-20
```

Nobody ran `checkov` by hand, and nobody reviewed the agent's diff before it went out. A pull
request did the reviewing, automatically. It failed for a real reason: the same `CKV_SECRET_2`
finding this course has used since Project 1, this time on an agent's own commit, named down to
the two lines it sits on.

## Stage 3: Send the failure back to the agent

### Step 1: Ask a second agent to fix the real cause

**Ask** a second, separate agent session to fix it, prompted with the real CI failure text plus
the pre-diagnosed cause and prescribed fix:

```
claude -p "You are on git branch m11-agent-proposed-demo, PR
schoolofdevops/310-agentic-iac-book#1. Its CI just failed: checkov reported CKV_SECRET_2 'AWS
Access Key' against modules/module-11-agentic-gitops/lab/pipeline-demo/main.tf. Read that file,
find the cause (signing_key_id has a hardcoded default), fix it: remove the default, mark it
sensitive = true, update the description to say how it should actually be set. Do not touch the
unrelated webhook_token variable. Commit and push." \
  --permission-mode acceptEdits --allowedTools "Read,Edit,Bash(git *)"
```

`[ Expected output ]`
```
Done. Pushed aa790ee to m11-agent-proposed-demo.

Cause: main.tf:19 had default = "AKIA3XQ7PZVK9RTLM2WD". The AKIA prefix matches checkov's
AWS-access-key regex, so CKV_SECRET_2 fires on any committed literal of that shape.

Fix, signing_key_id only:
- dropped default, so the variable is now required
- sensitive = true, so it stays out of plan and state output
- description now says set via TF_VAR_signing_key_id, mirroring webhook_token

webhook_token untouched.
```

### Step 2: Watch the gate pass

**Ask** the same PR for its result again:

```
gh pr checks 1
```

`[ Expected output ]`
```
contract	pass	4s	https://github.com/schoolofdevops/310-agentic-iac-book/actions/runs/36970938848/job/110724571478
gate	pass	35s	https://github.com/schoolofdevops/310-agentic-iac-book/actions/runs/36970938856/job/110724571495
```

Same gate, same scanner, same module. One commit changed, and the stage that failed now
passes.

## Stage 4: Merge and let GitOps apply it

### Step 1: Merge

This is the one manual step left in the whole loop, and notice what you're actually reviewing:
not `terraform fmt`, not the trivy run, not the checkov run, not even the diff line by line.
You're reviewing the outcome, a pull request that went from failing to passing for a documented
reason, and deciding whether that's good enough to ship:

```
gh pr merge 1 --squash --delete-branch
gh pr view 1 --json state,mergeCommit -q '[.state, .mergeCommit.oid] | @tsv'
```

`[ Expected output ]`
```
MERGED	73fcd2fdf28c27d51045e5489ae599ff2502854f
```

`gh pr merge` prints its confirmation line only to a terminal, so the second command is how a
scripted run, or a reader following along in a log, checks the same thing.

Two agent sessions proposed and fixed this change. Zero human edits touched the Terraform. One
human read a passing pull request and clicked merge. An agent's mistake reached a pipeline
before it reached a person, the pipeline caught it and said exactly why, a second agent session
fixed the actual cause instead of the symptom, and the only judgment call left for a human was
"is this diff, now that it's green, the right thing to ship." Stages 1 through 3 are done. What's
left is stage 4, the part where the merged result actually reaches a running cluster.

### Step 2: Stand up the cluster and install Argo CD

`file: lab/starter/kind-config.yaml`
```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: m11-lab
nodes:
  - role: control-plane
    image: kindest/node:v1.31.0@sha256:25a3504b2b340954595fa7a6ed1575ef2edadf5abd83c0776a4308b64bf47c93
```

```
kind create cluster --name m11-lab --config lab/starter/kind-config.yaml
kubectl --context kind-m11-lab create namespace argocd
kubectl --context kind-m11-lab apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl --context kind-m11-lab -n argocd wait --for=condition=available --timeout=240s \
  deployment/argocd-repo-server deployment/argocd-server
```

`--server-side --force-conflicts` isn't decoration either. Argo CD's own install manifest is
big enough that a plain client-side `kubectl apply` fails outright with an annotation-size
error the first time.

`--context kind-m11-lab` on every command from here on isn't decoration either. `kind create
cluster` changes your kubeconfig's current-context globally, so if you (or an earlier module)
still have another kind cluster around, creating this one can silently leave `kubectl` pointed
at the wrong cluster. Pinning the context makes every command below correct regardless of what
else is running on your machine.

### Step 3: Point Argo CD at the real, merged repo

`file: lab/solution/argocd-app.yaml`
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: m11-gitops-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/schoolofdevops/310-agentic-iac-book.git
    targetRevision: main
    path: modules/module-11-agentic-gitops/lab/gitops-demo
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

This is a real, public repo, this book's own companion repo `310-agentic-iac-book`, and
`lab/gitops-demo/` is a plain `ConfigMap` manifest merged there just now, the same repo you
opened a pull request against a moment ago.

```
kubectl --context kind-m11-lab apply -f lab/solution/argocd-app.yaml
```

**Verify** it goes `Synced` and `Healthy`:

```
kubectl --context kind-m11-lab get application m11-gitops-demo -n argocd
```

`[ Expected output ]`
```
NAME              SYNC STATUS   HEALTH STATUS
m11-gitops-demo   Synced        Healthy
```

**Confirm** the `ConfigMap` really landed:

```
kubectl --context kind-m11-lab get configmap m11-gitops-demo -n default -o jsonpath='{.data.message}'
```

`[ Expected output ]`
```
reconciled by GitOps, not kubectl apply
```

### Step 4: Watch self-heal for real

**Tamper** with the resource directly, the way someone might by accident:

```
kubectl --context kind-m11-lab patch configmap m11-gitops-demo -n default --type merge \
  -p '{"data":{"message":"manually tampered, should get corrected"}}'
kubectl --context kind-m11-lab get configmap m11-gitops-demo -n default -o jsonpath='{.data.message}'
```

`[ Expected output ]`
```
manually tampered, should get corrected
```

**Wait** a few seconds, and **check** again:

```
kubectl --context kind-m11-lab get configmap m11-gitops-demo -n default -o jsonpath='{.data.message}'
```

`[ Expected output ]`
```
reconciled by GitOps, not kubectl apply
```

Nobody ran anything the second time. The controller noticed the drift and corrected it on its
own. That's the mechanical difference from Terraform's one-shot model, felt directly instead of
just read about.

## Teardown

**1. Remove the Argo CD application:**

```
kubectl --context kind-m11-lab delete -f lab/solution/argocd-app.yaml
```

**2. Delete the cluster:**

```
kind delete cluster --name m11-lab
```

**Confirm** no orphan container is left behind:

```
docker ps -a --filter "name=m11-lab"
```

Empty output means clean.

#### Exercise

Point Argo CD's `syncPolicy` at manual instead of automated (`syncPolicy: {}` with no
`automated:` block), tamper with the ConfigMap the same way, and watch nothing get corrected
until you run `argocd app sync` yourself. Explain, in your own words, why `automated.selfHeal`
is what actually makes this step 5 rather than a still-manual step 4 with extra steps.

## Validation

Run the full check yourself, all four stages, start to finish, against a real `kind` cluster.
This is what catches a regression if the pinned Argo CD manifest, `kind` node image, or the CI
workflow's action versions ever change:

```
cd modules/module-11-agentic-gitops/lab
./run.sh
```

`run.sh` checks:

- The merged fix is real: `pipeline-demo/main.tf` carries both `sensitive = true` variables, no
  hardcoded default remains, and the agent-proposed `signing_key_id` variable is present
- A real `kind` cluster comes up, node image pinned by digest
- Argo CD installs clean, from the real upstream manifest
- Argo CD points at the real, merged repo and reconciles it
- A direct tamper on the resource gets corrected on its own, self-heal, for real
- Teardown removes the application and deletes the cluster, no orphan containers left behind

## Summary

What you built:

- An automated CI gate on GitHub pull requests: fmt, validate, Trivy, Checkov, running whether
  or not anyone is watching
- A real pull request, opened by an agent, no human touching the diff first
- A real CI failure, caught by the gate, on the agent's own hardcoded secret
- A second agent fixing the real cause, from the CI output alone, not a guess
- A merge, the only manual step in the whole chain, reviewing one outcome instead of a diff
- A real Argo CD install reconciling a real cluster from that merge, unattended, including
  correcting a real manual tamper on its own

This is step 5 on the autonomy ladder, supervised autonomy, for real: you reviewed outcomes,
propose and merge, not each gate, each fix, or each sync event in between. M12 asks what happens
when the loop itself, not just one pipeline, runs across many agents at once.
