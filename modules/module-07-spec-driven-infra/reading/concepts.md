# Chapter 7: Spec-Driven Infrastructure

## Recap: A One-Line Intent Was Enough, Once

**The project this chapter builds:** a real autoscaling web tier for a checkout service, built
twice from the same one-line ticket, once with a written spec first and once by feel, then
compared against the same real, applied infrastructure.

Module 1's lab handed you a single line: give me a local nginx container, serving a page you
control, nothing exposed outside the machine. That was fine. It was a first exercise, small
enough that one sentence carried the whole ask.

Real work rarely comes in one sentence. It comes as a ticket. Something like: give me an
autoscaling web tier for our checkout service. Read that again. It says nothing about how long a
slow-starting instance gets before it's assumed dead, which instance dies first when the tier
scales in, how big "auto" is allowed to get, or how fast it should react to a real spike. It
leaves almost everything for you to decide. That silence is normal. Most tickets look exactly
like this, and an autoscaling group has more places for that silence to turn into a real decision
than a single resource ever did. It is exactly where this chapter starts.

## What a Spec Has That an Intent Doesn't

![Two boxes side by side: a one-line intent with a single arrow going straight to generated code, next to a written spec broken into three labeled parts, requirements, constraints, and acceptance criteria, each with its own arrow into generation.](./diagrams/intent-vs-spec.svg)

A one-line intent has a goal and nothing else. A real spec has three separate parts, and each one
does a different job.

**Requirements** state what the thing must do. Survive a real cold boot without being killed as
unhealthy. Protect the newest release during a routine scale-in. Each one specific enough that you
could check it later without asking the person who wrote it what they meant.

**Constraints** state what the thing must never do. No hardcoded account ID inside a resource
block. No unbounded capacity ceiling nobody measured against. A requirement says what to build. A
constraint says what to refuse, even if it would be the easy path.

**Success criteria** state, before anything is generated, exactly how you will check the result.
Not "does it look right." A specific, testable line: `health_check_grace_period` equals `180`. You
could hand that line to someone who never read the ticket, and they could still check your work.

Write these three things down before you generate a single line of Terraform, and you have a
spec. Skip them, and you have a guess with good intentions.

## Vibe Coding, Named

There is a name for skipping all three: vibe coding. Generate something. Look at it. Ask for a
small tweak. Look again. Repeat, with no written target and no fixed criteria, until it feels
close enough.

![A loop: generate, eyeball, tweak, eyeball again, going in a circle with no exit arrow and no written target box anywhere in the loop, crossed out with a single stroke.](./diagrams/vibe-coding-loop.svg)

This is named here once, because it already failed on infrastructure, in a specific and
checkable way, not because it's a technique worth weighing against spec-driven work. Here's what
actually goes wrong. Generate an autoscaling tier from "give me an autoscaling web tier for our
checkout service," with no requirements list in front of you, and you don't get a broken module.
You get a competent-looking one: a load balancer, security groups, a launch template with real
boot logic, an autoscaling group, a scaling policy. Nobody would flag it in a five-second glance
at a PR. It just quietly picked a plausible-looking number for every real decision the ticket left
open, a health check grace period too short for a real cold boot, a scale-in policy that can kill
the newest code first, a capacity ceiling nobody measured against, a five-minute default cooldown
built for a slower-moving workload than a flash sale.

`terraform apply` doesn't know the difference between that and a careful, spec-driven module.
Both are valid HCL. Both apply cleanly. The gap only shows up later, when the tier thrashes
because a healthy instance kept getting killed for booting too slowly, or a canary release gets
scaled away on the very host it needed protected, or worse, when nobody catches it at all.
Application code that's "close enough" usually gets a chance to be fixed in the next release.
Infrastructure that's "close enough" is often already live, already serving real traffic, before
anyone reads it carefully. That's M01's asymmetry again: no undo, and failure that stays quiet
until someone goes looking.

## Spec Kit and Kiro Specs

![Four boxes in a row, specify, plan, tasks, implement, each an arrow into the next, with the spec document sitting above all four as the thing each stage reads from and writes back to.](./diagrams/spec-kit-workflow.svg)

You don't have to invent your own spec format. GitHub's Spec Kit gives you a real, structured
one. Install it, and it drops a set of skills into your coding agent: `/speckit-specify` writes
the baseline spec, `/speckit-plan` turns it into an implementation plan, `/speckit-tasks` breaks
that into actionable steps, and `/speckit-implement` generates against all of it. Kiro specs work
the same pattern, a different tool, the same underlying idea: write the spec, then generate against
it, then check the result against what you wrote.

A Spec Kit spec has a fixed structure you'll recognize from the section above. Functional
requirements, written as `FR-001`, `FR-002`, numbered so you can point at exactly one. Success
criteria, numbered the same way, `SC-001`, `SC-002`, stated as something you could check with a
command, not something you'd have to eyeball. This isn't ceremony for its own sake. Numbered,
checkable lines are what let you verify a generated module against the spec instead of against
your memory of what you meant.

## Generate Against a Spec, Then Check It, Line by Line

![A spec document feeding into an agent, the agent generating a module, and the module being checked against each numbered acceptance criterion from the spec, one arrow per criterion, not one arrow labeled "looks right."](./diagrams/generate-against-spec.svg)

Once the spec exists, generation is almost the boring part. Hand it to your agent, get a module
back, and check it against the spec's own criteria, one by one. Did the health check grace period
end up `180`? Check the applied state. Did the scale-in policy end up protecting the newest launch
template version? Check the applied state. Not "run it and see if it looks fine." A line-by-line
pass against lines you wrote down before you saw any code.

Here's the honest part, and it matters as much as the success. A spec's success criteria only
cover what its author thought to write down. Write a spec for an autoscaling tier with five
requirements, and a scanner will very likely still find things outside those five: missing tags on
the launch configuration, no encrypted root volume, no detailed monitoring. None of that is a
failure of spec-driven work. It's the spec doing exactly what it promised, no more. A spec defines
what gets generated. It was never supposed to replace what checks it afterward.

### Try it: spec-driven vs vibe-coded

Pick a path for the same autoscaling-tier ask and watch the real checkov numbers from this
module's own lab play out: [Spec-Driven vs Vibe-Coded Simulator](../explainer/sim/spec-vs-vibe-sim.html).

**Seeded failure:** the same one-line ticket, give me an autoscaling web tier for our checkout
service, answered without a spec, diverges from the same ticket answered with one on five real
judgment calls: health check grace period, scale-in termination policy, capacity ceiling, scaling
cooldown, and IMDSv2. **Caught by:** real `terraform plan` values compared line by line between
the two modules, plus checkov, which passes `CKV_AWS_79` on the spec-driven module and fails it,
plus nine more findings on an unrequested ALB, on the vibe-coded one. **Fixed by:** the
spec-driven module, whose live state checks out against SC-001 through SC-004, with SC-005 and
SC-006 verified separately by checkov earlier in the same lab, every one of the six written into
`spec.md` before any code existed.

## Spec vs Gate vs Policy: Three Different Jobs

![The M01 authority-boundary line, now with three real stages marked on it: a spec box shaping the intent before generation, a gate box (M06) blocking apply, and a policy box (M09) checking the plan, each labeled with what it does and what it does not do.](./diagrams/spec-gate-policy.svg)

It's tempting to think a good spec makes the later gates unnecessary. It doesn't, and this is
worth stating plainly so the three don't blur together.

A spec defines the ask, before generation happens at all. It's nothing but a better question. A
gate, the kind you built in M06, blocks `apply` based on something mechanical: a blast radius, a
missing approval. A policy check, the kind M09 runs, scans the generated plan against rules
neither you nor the spec's author necessarily thought of. Three different jobs, three different
moments in the pipeline, and none of them stands in for the other two. `apply` still needs a
gate whether the module came from a careful spec or from ten seconds of guessing, because the
gate isn't checking how the module got written. It's checking what it's about to do.

## When It's Worth Writing One

![A simple decision split: on one side, a throwaway Tier 0 exercise, arrow to "a one-line intent is enough"; on the other side, anything with real reviewers or real consequences, arrow to "write the spec."](./diagrams/when-worth-it.svg)

A spec costs real time to write. That cost is worth paying whenever the answer to any of these is
yes. Will someone other than you review this? Will it hold real data or run in a real account?
Will you, six months from now, need to remember what "done" meant here? A one-line intent is
still fine for a throwaway exercise, a Tier 0 sandbox, something nobody but you will ever look
at again. The moment a real reviewer or a real consequence enters the picture, the ticket you got
handed deserves the three extra sections this chapter just walked through.

## One Language, Two Runtimes

Terraform is BUSL-licensed. OpenTofu, the Linux Foundation fork, is MPL-2.0. The
lab's Step 6 applies the exact same spec-driven module twice, once with each
binary, no changes to the `.tf` files, and both runs produce the same three
resources with the same values. For a module with no provider-specific
Terraform-only features, the choice between them is a license and tooling
decision, not a different infrastructure outcome.

## Vocabulary

| Term | Plain definition |
|---|---|
| Spec-driven development | Writing requirements, constraints, and acceptance criteria before generating anything, instead of iterating on a result by feel |
| Requirement | A specific, checkable statement of what a thing must do |
| Constraint | A specific, checkable statement of what a thing must never do |
| Acceptance criteria | A stated, checkable line for how you will verify the result, written before generation, not after |
| Spec Kit | GitHub's structured spec-writing tool, installed as agent skills: specify, plan, tasks, implement |
| Kiro specs | A different tool for the same underlying idea, spec first, generate second |
| Vibe coding | Generating and iterating by feel, with no written spec and no fixed acceptance criteria. Named once in this course, as a failed approach on infrastructure specifically |
