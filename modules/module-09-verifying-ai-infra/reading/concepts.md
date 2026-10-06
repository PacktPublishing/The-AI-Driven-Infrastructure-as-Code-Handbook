# Chapter 9: Verifying AI-Generated Infrastructure

## Recap: The Pipeline From M01

Since module one you have carried one sentence around: the agent proposes, the pipeline
decides. Module six built the first real piece of that pipeline, a hook that could block
an unsafe apply. This chapter builds the rest of it, and applies it to one real project: a
small S3 module for a reports-and-backups service, two buckets, both shipped deliberately
unhardened. By the end, "the pipeline decides" stops being a slogan and becomes four
real tools, run in a fixed order, against that project.

## The Opening Demo: Same Code, Two Answers

Here is a fact worth sitting with. Take one Terraform module, twenty one resources, a
real three tier module with a VPC, an EC2 instance, and an RDS database. Scan it with
Trivy. Then scan the exact same files with Checkov. You would expect roughly the same
answer, would you not? You do not get one.

![Two scanners pointed at the same Terraform code, returning different finding counts, Trivy 7 and Checkov 25, drawn as two separate report cards from one input.](./diagrams/opening-demo.svg)

Trivy reports **7 HIGH or CRITICAL findings**. Checkov reports **25 failed checks**. Same
code, same run, same day. This is not a bug in either tool. It is the real, reproducible
result of `labs/shared/floci-spike/run.sh` in this course's own repository, and this
chapter's own lab reproduces it again, live, on your machine, in under a minute.

## Why They Disagree

Neither number is wrong. Trivy and Checkov each ship their own rule set, and for
Terraform's AWS resources, the two rule sets only partly overlap. Checkov's is the
strictly larger one here: it checks things like cross region replication, event
notifications, and lifecycle configuration that Trivy's rule set does not encode at all
for this resource type. Trivy, in turn, sometimes splits one Checkov check into several
more granular ones, for example separate findings for blocking public ACLs, blocking
public policies, and ignoring public ACLs, where Checkov collapses that into one public
access block check.

![Two overlapping circles representing Trivy's rule set and Checkov's rule set for Terraform AWS resources, with Checkov's circle larger and only partial overlap between them.](./diagrams/rule-set-overlap.svg)

That is the whole lesson in one sentence: **running one scanner is a coverage gap, not a
safety margin.** You would not ship with only one of the four asymmetries from module one
checked. Do not ship with only one scanner either.

## What Neither One Catches

Even running both tools together, there is a category of rule neither one will ever
check, because neither one knows your team exists. Say your organization requires every
`aws_s3_bucket` to carry an `Owner` tag, so someone is on the hook when it shows up on a
bill. Trivy does not know that rule. Checkov does not either. It is not a security rule
in the generic sense, it is *your* rule.

This is what **OPA**, the Open Policy Agent, and its command line front end **Conftest**,
are for. You write the rule once, in a small policy language called Rego, and Conftest
checks every plan against it, the same way Trivy and Checkov check plans against their
own built in rules.

![A Terraform plan flowing through Trivy and Checkov's generic rule sets, then through a third, org-specific gate labeled Conftest, checking a rule neither generic scanner encodes.](./diagrams/opa-gap.svg)

This chapter's lab has you write exactly this policy, watch it fail on a real,
unfixed module, fix the module, and watch it pass.

**Seeded failure:** `module/main.tf` ships both buckets with no versioning, encryption, or
public access block, and only `backups` carries a tags block, leaving `reports` untagged.
**Caught by:** Trivy and Checkov scanning the module directly, 16 and 14 real findings across
both buckets, plus a hand-written OPA policy, `required_tags.rego`, failing conftest on
`aws_s3_bucket.reports` by name for its missing `Owner` tag. **Fixed by:** switching to
`solution/main.tf`, the same module with tags, versioning, a public access block, and KMS
encryption added to both buckets, which clears Trivy and Checkov in `pipeline.sh` and passes
conftest clean.

## A Cost Check, Wired Honestly

Most teams that use **Infracost** use it the way you would use a smoke detector that
never rings, they read the estimate once, and move on. That is a report, not a gate. A
gate is a check that can actually stop a plan, the same way Checkov's exit code stops
`apply` when it fails.

This chapter does not build that gate yet. Its pipeline wires Infracost in honestly: run
the real estimate if you have a key, or skip the stage with a clear message if you do
not, never a guessed number. It fails only if the Infracost CLI itself errors, not
because a plan crossed a dollar figure or an instance type ceiling. Module 12 builds the
piece this chapter leaves out, a FinOps check that reads a real plan and fails the
pipeline for real once a threshold is crossed, the same way Checkov's exit code already
does here.

Infracost's own CLI needs a one-time, free account to fetch live pricing, no credit card,
just a signup and a device login. Set up your own key before the lab if you want to see
this stage run for real.

## Order Matters

Put the cheapest, fastest checks first. `terraform fmt` and `validate` take under a
second and catch a typo before you spend a scanner's runtime on it. Scans come next,
they are seconds to tens of seconds. Policy checks after that. Cost estimation, which
sometimes calls out to a pricing API, comes after the checks that can fail for free.
Human approval, the most expensive step of all because it spends a person's attention,
comes last, only once everything upstream has already said yes.

![A five stage pipeline in order: fmt and validate, scan, policy, cost, human approval, apply, drawn as a left to right sequence with cheap fast checks on the left and the expensive human step near the right.](./diagrams/pipeline-order.svg)

Get this order backwards, run the expensive check first, and you waste a person's
attention on a plan that a one second `fmt` check would have caught.

## The Assembled Pipeline

Put it together and you get the concrete version of module one's authority boundary
diagram, every stage now a real, runnable tool instead of a label:

**scan (Trivy, Checkov) → policy (Conftest) → cost (Infracost) → human approval → apply**

![The M01 authority boundary diagram, now with every stage named as a real tool: Trivy and Checkov for scan, Conftest for policy, Infracost for cost, then human approval, then apply.](./diagrams/pipeline-assembled.svg)

The agent's job ends at generating a plan. Everything after that line is the pipeline's
job, and now you have built every piece of it, from the hook in module six through the
four tools in this chapter.

### Try it: the pipeline gate walkthrough

There is a small, interactive tool that makes this concrete:
[Pipeline Gate Walkthrough](../explainer/sim/pipeline-gate-sim.html). Toggle any stage to
fail, run the pipeline, and watch it stop exactly there, with every stage before it still
counted as passed and everything after it never reached at all, including human approval.
Toggle everything back off and run it again to see a clean pass reach `apply`.

## Verifying the Infrastructure Is Not Verifying the Agent

Every check built so far in this chapter asks a version of the same question: is this
*infrastructure* safe. Trivy and Checkov ask it about known misconfigurations, Conftest
asks it about your own org's rules, the cost check asks about price, though this
chapter's version only fails on a broken Infracost run, not a crossed threshold. None of
them ask whether the agent actually did what it was told.

That second question needs a different kind of check: a rubric, plain code, that grades
the agent's own output against a fixed, written expectation, with no model involved in the
grading. Module eight already gave you the discipline behind this, verification-before-claiming: a
claim only counts once real evidence backs it up. This chapter's eval rubric is that same
discipline turned on the agent's Terraform output specifically, checking a concrete rule
(M04's required tags: `Environment`, `Owner`, `ManagedBy`) rather than trusting the agent's
own account of what it wrote.

Run both kinds of check, and for a different reason each time. The scan-and-policy pipeline
still decides whether the resulting infrastructure is safe to apply. The eval rubric decides
whether the agent's output actually matches what was asked, a distinct question one can pass
while the other fails.

## What Tier 1 Still Cannot Show You

Be honest about the limits of what you just built. Floci gives you a real, API level
emulation, good enough to run real scanners against real plans and get real answers. It
cannot show you a real cloud bill, real IAM enforcement, or infrastructure that drifts
over months of real traffic. Those stay out of reach until module ten's Tier 2 labs and
the capstone's optional Tier 3.

![A short honest list of what Tier 1 emulation cannot show: real cloud cost, real IAM enforcement, real drift over time, each crossed lightly to signal a known limit, not a failure.](./diagrams/whats-missing.svg)

## Vocabulary

| Term | Meaning |
|---|---|
| Trivy | A misconfiguration and vulnerability scanner, one of two scanners this course always runs together |
| Checkov | The second scanner this course always runs, with a broader Terraform rule set than Trivy for most AWS resources |
| OPA | Open Policy Agent, a general purpose policy engine for rules generic scanners do not encode |
| Conftest | The command line tool that runs OPA policies against structured input like a Terraform plan |
| Rego | The policy language OPA and Conftest policies are written in |
| Cost check | This chapter's Infracost stage: runs the real estimate if you have a key, skips honestly if you do not, fails only on a broken CLI run, not a crossed threshold. The FinOps gate in M12 is the one wired to actually fail past a real threshold |
| Plan-diff review | The human step where a person reads what a plan would actually change, after every automated gate has already passed |
| Eval rubric | A deterministic, model-free check that grades an agent's own output against a fixed rule, separate from whether the resulting infrastructure passes the scan-and-policy pipeline |
