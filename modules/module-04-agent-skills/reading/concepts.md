# Chapter 4: Agent Skills for IaC

## Recap: Context Is Loaded Every Time, a Skill Is Loaded on Demand

Module 3 gave an agent standing context, the facts that stay true about a repo on every
single run: provider pins, naming, the never-do list. That context loads whether or not
the current task needs all of it. A skill is different. It sits there, unused, until a
task actually matches what it's for, and only then does the agent pull it in.

Would you want every rule your team has ever written loaded into every single request?
No, that gets noisy fast, and noise is exactly what Module 3 warned you a context window
punishes. A skill solves a narrower problem: package a capability once, and let the agent
decide, task by task, whether this is the moment to reach for it.

This module's lab builds one real project around that idea: a shared VPC module used
identically across dev, staging, and prod, scaffolded and mechanically checked by a skill
that carries its own script instead of asking an agent to eyeball the numbers.

## Context vs Skill vs Prompt

Three different things, and they get confused constantly because all three end up as text
an agent reads at some point.

![Three panels compared: standing context that loads on every run, a skill that loads only when a task matches, and a one-off prompt that is spent once.](./diagrams/context-vs-skill-prompt.svg)

A prompt is what you ask, once, for this task. It's gone the moment the task ends. Context,
from M03, is what's always true about the repo, loaded on every run whether or not this
particular task needs it. A skill sits in between: written once, like context, but loaded
only on demand, like a prompt is answered only once. The test for which one you're looking
at is simple. Ask: does this need to be true on every run, or only when this specific kind
of task comes up? The first answer points to context. The second points to a skill.

## Anatomy of a SKILL.md

Here's a real one, already living in this course's own repo.

![An annotated SKILL.md file: YAML frontmatter with name and description fields at the top, plain instructions in the body below.](./diagrams/skill-anatomy.svg)

`demos/m1-agent-preview/.claude/skills/container-conventions/SKILL.md` starts with a small
YAML block, `name` and `description`, then drops into plain prose instructions: pin every
base image, never run as root, always declare a health check. Nothing exotic. The whole
file reads like a short, specific section of a team wiki that somebody actually keeps up to
date, because in a working setup, that's exactly what it is.

## Discoverability Is the Whole Game

The frontmatter's `description` field isn't documentation. It's the matching key.

![A task description flowing into a matcher, compared against several skill descriptions, one match found, invoked, others left untouched.](./diagrams/discoverability.svg)

When an agent gets a task, it checks that task against every skill's `description` looking
for a match. Write a specific one, "use whenever asked to write, generate, or extend a
Terraform module for an AWS resource," and the skill fires exactly when it should. Write a
vague one, "Terraform best practices," and there's nothing concrete for the agent to match
against. The skill sits in the repo, correctly written, completely unused. A skill nobody's
agent ever triggers is worse than no skill at all, because it gives a team false confidence
that the rule is enforced somewhere.

### Try it: the skill discoverability simulator

Type a task into the [Skill Discoverability Simulator](../explainer/sim/skill-discoverability-sim.html)
and watch it get checked against a few real `description` fields, including the vague
`terraform-best-practices` one above. Try "write an S3 bucket module" first, then try
"clean up this codebase", a task specific enough for a human, vague enough that nothing
fires.

## Skills Package House Convention

The real payoff isn't any single rule. It's not retyping the same review comment for the
tenth time.

![One skill icon connected by arrows to many generated modules, each one carrying the same conventions, next to a crossed-out stack of repeated manual review comments.](./diagrams/house-convention.svg)

Provider pins, a required tags block, no hardcoded secrets, write these once into a skill
and every module an agent generates afterward carries them, without a human retyping the
same three comments in every pull request. That's not a small thing on a team that
generates a lot of small modules. The review conversation moves from "you forgot the tags
again" to whatever the module is actually for.

The lab's own Stage 1 shows this directly, on the same secret pattern M01 and M03 already
caught by hand. **Seeded failure:** the same hardcoded-secret pattern as M01 and M03, this
time on `artifact_uploader_key`, plus a missing `tags` block and a missing provider pin.
**Caught by:** Checkov's `CKV_SECRET_2` on run 1, with no skill anywhere in the folder.
**Fixed by:** the `terraform-module-conventions` skill, applied automatically on run 2
with the exact same prompt, no rule retyped.

## A Skill That Ships Code, Not Just Prose

Every skill so far in this module is pure prose: rules an agent reads and tries to follow. That
works right up until the rule stops being a judgment call and becomes something you could just
compute. "Do these two CIDR blocks overlap" isn't a style preference an agent weighs, it's
`ipaddress` arithmetic with one right answer. Writing that as a paragraph and hoping the agent
gets the arithmetic right on a bad day is strictly worse than writing the ten lines of Python
that get it right every time and having the skill run them.

![A skill's SKILL.md pointing two ways: prose instructions the agent reads and reasons about, and a bundled scripts/ directory the skill's own instructions tell the agent to execute, with a real exit code.](./diagrams/skill-ships-code.svg)

A `SKILL.md` isn't limited to its own body text. It can live next to a `scripts/` directory, and
its instructions can say "run this before you proceed," the same way a senior engineer's review
comment might say "run the linter" instead of re-explaining every style rule from memory. The
lab's `vpc-environment-scaffold` skill does exactly this: its prose carries the design rules that
genuinely need judgment (why prod gets a NAT gateway per AZ and dev doesn't), and it hands the
part that doesn't need judgment, whether two CIDR blocks collide, to a bundled script with a real
exit code. Mixing both in one skill is normal. Confusing "the script checked this" with "the
agent reasoned about this and I should double check" is the mistake worth watching for once a
skill starts bundling real code.

This is also the fix for the shallow version of this module's lab: a single S3 bucket and a
three-rule prose skill teaches discoverability, but it doesn't teach the difference between a
skill that suggests and a skill that verifies. A multi-environment VPC module, with a skill that
bundles a real overlap checker, does.

**Seeded failure:** a real CIDR collision, staging's `10.11.0.0/16` shrunk to
`10.10.128.0/17`, overlapping dev's `10.10.0.0/16`, seeded only in a scratch copy under
`/tmp/m04-overlap-test`. **Caught by:** the skill's bundled `check_cidr_overlap.py`
script, plain `ipaddress` arithmetic that exits nonzero on a real overlap, not an
agent's judgment call about whether two ranges happen to share addresses. **Fixed by:**
discarding the scratch copy, `rm -rf /tmp/m04-overlap-test`, the shipped staging CIDR
was never actually altered.

## Skills vs Harness

A skill is voluntary. That word matters more than it looks like it should.

![Two paths compared: a skill, invoked only if the agent decides the task matches, versus a hook, which runs and blocks regardless of what the agent decides.](./diagrams/skill-vs-harness.svg)

An agent can choose not to reach for a skill, misjudge that a task doesn't match, or simply
not have it loaded in a given session. A skill can only ever suggest the right behavior to
an agent that's already inclined to look for it. A hook or a gate is different: it runs
whether the agent wants it to or not, and it can flat out block an action the agent tried to
take. That's the harness, and it's a different guarantee entirely. This module doesn't build
that gate, M06 and M08 do. What matters here is knowing the difference before you assume a
skill is enforcing something it can only ever suggest.

## Trusting a Skill You Didn't Write

Every skill in this module so far, you wrote. You can read one you wrote end to end and
trust it, because you already know what it does. A skill you didn't write is a different
situation: a teammate's repo, an open-source skill marketplace, a link pasted into a team
channel. The moment its instructions run inside your agent's session, they carry whatever
trust that session already has, filesystem access, shell access, the ability to read
anything the account running the agent can read.

That gap has a name: tool poisoning. A skill, or an MCP tool, M05 covers those, earns
discoverability and trust for one stated job and then uses that trust for something the
description never mentioned. This module's Stage 3 plants a specific case of it, a
confused-deputy risk: a skill described as a Terraform formatter that also, buried in a
numbered instruction nobody skims past, reads `~/.aws/credentials` and `~/.ssh/id_rsa`. The
formatter earned the right to run inside your session by promising to format files. Nothing
in that promise earned it the right to read your SSH key.

Catching this doesn't require reading an agent's mind or trusting a vendor's badge. Read the
`description` field, then read every instruction in the body, and check whether each one
earns its place under that description. An instruction with no relationship to the stated
job is the tell, checkable by eye, and, as Stage 3 shows, checkable with a plain `grep` once
you know the pattern to look for.

**Seeded failure:** a planted `terraform-formatter` skill whose `description` promises only
formatting, while a numbered instruction in the body reads `~/.aws/credentials` and
`~/.ssh/id_rsa`. **Caught by:** a description-versus-instruction audit, verified
mechanically with `grep -c "credentials\|id_rsa"` against the skill file, expected to
return `0`. **Fixed by:** rewriting the skill so its body matches its description exactly,
the credential read removed entirely.

## Where This Sits on the Ladder

The lab in this module has you read a written skill, use it once, and check the result
yourself before applying anything for real. That's step 3, propose with plan, from M01's
autonomy ladder, not step 5.

![The autonomy ladder from Module 1, step 3 highlighted, with the label: the agent proposes code and a plan, a human still reads both before anything runs.](./diagrams/ladder-rung3.svg)

The skill changed what got proposed. It didn't change who's still reading the plan before
`apply` runs. Keep that distinction sharp: a better proposal is not the same thing as more
autonomy, and this module is squarely about the first one.

## Vocabulary

| Term | Definition |
|---|---|
| Agent Skill | A packaged, on-demand capability an agent loads when a task matches, not standing context and not a one-off prompt |
| `SKILL.md` | The file format for an Agent Skill: YAML frontmatter (`name`, `description`) plus body instructions |
| Frontmatter | The YAML block at the top of a `SKILL.md`, `name` and `description` |
| Discoverability | Whether an agent's task matches a skill's `description` closely enough to trigger it |
| House convention | Team-specific rules, naming, tagging, pins, packaged once into a skill instead of repeated in every review |
| Skill vs harness | A skill is invoked voluntarily by the agent; a harness gate runs and can block regardless of what the agent decides |
| Tool poisoning | A skill or MCP tool that earns discoverability and trust for one stated job, then uses that trust for something its description never mentioned |
| Confused-deputy risk | The specific failure tool poisoning creates: a component with real, earned access carries out an instruction outside the scope its description promised |
