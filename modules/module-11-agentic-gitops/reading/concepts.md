# Chapter 11: Safe Agentic Delivery to Production

## This Chapter Is Not Really About GitOps

Say that plainly, up front, because the lab has Argo CD in it and it would be easy to
walk away thinking that's the subject. It isn't. GitOps is the last link in a chain this
chapter is actually about: **what has to be true for an agent's production change to be
safe to ship without a human reading every line it wrote.** Four things, each doing one
job, none of them optional:

1. **Propose.** An agent makes a change and opens a pull request. Nobody reviewed it
   before it went out.
2. **Automated review.** A pipeline runs on that pull request, on its own, and catches
   what the agent didn't.
3. **Human merge.** One person reads one outcome, a passing or failing pull request, and
   decides.
4. **Apply.** Whatever merged lands on the target, correctly, without anyone typing
   `kubectl apply` or `terraform apply` by hand.

GitOps is step 4. It's real, it's useful, and this chapter builds it for real. But it is
the easy 25% of the chain. The hard part, the part that actually makes an agent trusted
with production, is steps 1 through 3, and the lab spends most of its time there on
purpose: an agent proposes a real change with a real mistake in it, a real pipeline
catches the mistake and says why, a second agent fixes the real cause, and a human merges
the outcome. Only then does GitOps take over.

The lab in this module builds exactly this, one real pipeline, end to end: an agent opens a
real pull request against this course's own public labs repo, a real GitHub Actions workflow
gates it, and a real Argo CD install reconciles a real `kind` cluster once it merges.

## Recap: A Pipeline You Ran by Hand

Module 9 built a real pipeline: fmt and validate first, then Trivy and Checkov, then a
policy check, then a cost check, then a human approval, then apply. You ran every one of
those stages yourself, by typing a command. Module 6 built a hook that ran automatically,
but only when your own agent tried to act. Neither one runs on its own, on a repo nobody
is currently sitting at, catching a change an agent proposed while nobody was watching.

This chapter is where that changes. The same kind of pipeline gets wired into GitHub
Actions, so it runs on every pull request, whether or not anyone is watching, whether the
change came from a human or an agent. And on the other side of a merge, a real controller
keeps a real cluster matching whatever's in the repo, continuously, without anyone running
`kubectl apply`.

## From Plan and Apply to Reconcile, in CI

Picture the M09 pipeline again: `terraform fmt`, `terraform validate`, Trivy, Checkov, a
policy check, a cost check. Every one of those is a shell command. A CI workflow is
nothing more than a machine that runs those same shell commands, in order, every time
someone opens or updates a pull request.

![A pipeline script running by hand next to the same stages inside a GitHub Actions workflow, triggered automatically on every pull request.](./diagrams/hand-to-ci.svg)

That's the whole idea, and it's worth saying plainly because it sounds bigger than it is:
nothing about the pipeline changes. What changes is who runs it. In module 9, you did.
Here, a pull request does, automatically, every single time, whether the change came from
a human or from an agent.

## GitOps in One Sentence

Here's the definition this chapter uses, and it's short on purpose: **the repo is the
source of truth, and a controller keeps the cluster matching it.** Nobody runs `kubectl
apply` by hand anymore. You change a file, you open a pull request, you merge it, and a
controller running inside the cluster notices the merge and makes the cluster match.

![A git repository as the single source of truth, with a controller drawn as a constant arrow comparing the cluster's live state against the repo and correcting any difference.](./diagrams/gitops-picture.svg)

This works differently than Terraform's plan-and-apply. Terraform runs once, changes
what it changes, and stops. A GitOps controller never stops. It keeps checking, forever,
and if something in the cluster drifts away from what the repo says, whether a person
changed it by hand or something else did, the controller notices and puts it back. You'll
see this for real in the lab: change a resource directly, watch the controller undo your
change within seconds.

## Argo CD and Flux: Synced and Healthy Are Two Different Questions

Argo CD and Flux are the two real, widely used controllers that do this job. Whichever one
a team picks, they both report state along two separate axes, and it's worth keeping them
apart:

- **Synced or out of sync** answers "does the cluster match the repo right now?"
- **Healthy or degraded** answers "is what's running actually working?"

![Two independent states, synced-vs-out-of-sync on one axis and healthy-vs-degraded on the other, shown as a small grid rather than a single checkmark.](./diagrams/synced-healthy.svg)

A resource can be synced and unhealthy at the same time: the cluster matches the repo
exactly, and the pod inside it is crash-looping anyway. Matching the repo says nothing
about whether the thing you asked for actually works. Watch both, not just one.

## The Full Loop, Traced End to End

Put the last few modules together and trace the whole path a change takes, start to
finish. This isn't hypothetical, it's what the lab actually runs:

An agent proposes a change and opens a pull request, in the lab's case, a Terraform
variable with a hardcoded key baked into its default, the kind of thing a developer in a
hurry writes without thinking twice. The CI pipeline, the one this chapter builds, runs
automatically: fmt, validate, Trivy, Checkov. It fails, for a real and specific reason,
`CKV_SECRET_2`, a hardcoded AWS-style key. Nothing merges until that's fixed. A second
agent, prompted with the CI failure text plus the pre-diagnosed cause and prescribed fix,
applies it, marking the value sensitive instead of guessing at a workaround. CI goes green. A
human reads the pull request, not each individual gate, and merges it. The moment that
merge lands on the branch the controller watches, reconciliation kicks in on its own and
the cluster converges to match, with nobody typing `kubectl apply`.

**Seeded failure:** the agent-opened pull request commits a hardcoded AWS-style access key as
the default for a new `signing_key_id` Terraform variable. **Caught by:** the CI gate's
Checkov stage, `CKV_SECRET_2`, failing on the agent's own commit while Trivy's stage passes
clean. **Fixed by:** a second, separate agent session, prompted with the CI failure text plus the
pre-diagnosed cause and prescribed fix, removing the default and marking `signing_key_id`
`sensitive = true`.

![The full loop drawn as one continuous path: propose, automatic gate, human merge, automatic reconcile, no other manual step anywhere on the path.](./diagrams/full-loop.svg)

Count the manual steps in that loop. There's exactly one: the human reading the pull
request and deciding to merge it. Everything before that step and everything after it
runs on its own.

### Try it: the full GitOps loop

[The Full GitOps Loop](../explainer/sim/gitops-loop-sim.html) steps through exactly this
path, one stage at a time: propose, the automatic gate, the one human click, the automatic
sync, healthy. Click through to the end, then hit the tamper button and watch the
controller self-heal a change made directly against the cluster, the same test this
module's own lab ran for real.

## Step 5, Precisely

Go back to the autonomy ladder from module 1. Step 4, gated apply, means automated checks
plus a human approval, one specific action approved at a time. Step 5, supervised
autonomy, means the agent loops on its own across multiple actions, and a human reviews
outcomes rather than approving each individual step.

This chapter's loop is the first place in the course where step 5 is genuinely real,
not just described. The CI pipeline runs multiple stages on its own. The controller keeps
reconciling on its own, indefinitely, well past the moment of the merge. The one thing a
human still does is review the pull request's outcome, the diff, the passing checks,
before it merges. Nobody is reviewing the `terraform fmt` step separately from the
Checkov step separately from the sync event three minutes later. That's supervised
autonomy: a human watching outcomes, not steps.

![The M01 autonomy ladder, step 5 highlighted, with a note showing exactly what is now automatic (every gate, every sync) against the one thing that still needs a human (reading and merging the pull request).](./diagrams/step5-precisely.svg)

It's also worth saying what this is not. Step 6, unattended, would mean even the merge
itself happens without a human. This course does not teach that as a default, and this
chapter doesn't build it. The gap between step 5 and step 6 is not a technical gap, every
piece needed to remove the human from the merge already exists. It's a trust gap, and
closing it on purpose, deliberately, with eyes open, is a decision for a team to make
later, not a default this chapter recommends.

## What This Doesn't Close

Two real gaps stay open here, named honestly rather than hidden. First, rollback: this
chapter's controller reconciles forward, toward whatever the repo currently says. Getting
back to a known-good state after a bad merge is a real practice with its own tooling and
its own care, and it's out of scope here. Second, incident response: when reconciliation
itself is the thing failing, who gets paged, and what do they do first? Also out of scope.
Both are real, both matter in production, and pretending this chapter covers them would be
worse than saying plainly that it doesn't.

![Two labeled gaps, rollback and incident response, drawn as open doors at the end of the loop diagram rather than closed and solved.](./diagrams/open-edges.svg)

## Vocabulary

| Term | Meaning |
|---|---|
| Propose | An agent makes a change and opens a pull request, unreviewed |
| Automated review | A pipeline runs on the pull request on its own and catches what the agent didn't |
| Human merge | One person reads one outcome, a passing or failing pull request, and decides |
| CI pipeline | The M09 pipeline's stages, wired to run automatically on every pull request |
| GitOps | The repo is the source of truth, a controller keeps the cluster matching it; the "apply" step in propose/review/merge/apply |
| Argo CD / Flux | Real controllers that reconcile a cluster against a git repo |
| Synced | The cluster currently matches what the repo says |
| Healthy | What's running is actually working, independent of whether it's synced |
| Reconcile | The controller's continuous act of comparing and correcting, never a one-shot |
| Step 5, supervised autonomy | A human reviews outcomes (a merged PR, a sync event), not each individual gate or step |
