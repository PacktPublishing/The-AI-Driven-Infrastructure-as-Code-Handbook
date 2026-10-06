# M04 Reference Card: Agent Skills for IaC

## SKILL.md frontmatter

```
---
name: short-kebab-case-name
description: What this skill is for and exactly when to use it.
---
```

- `name`: short, kebab-case, matches the directory name
- `description`: the matching key. Name the concrete trigger ("use whenever asked to
  write, generate, or extend a Terraform module for an AWS resource"), not a vague
  category ("Terraform best practices")

## Discoverability checklist

- [ ] Does the `description` name the specific task type, not just the general topic?
- [ ] Would a teammate reading only the `description` know exactly when this fires?
- [ ] Is the body a flat set of rules, not a wish list or a style essay?
- [ ] Did you test it: same intent, skill present vs skill absent, real diff?

## Context vs skill vs harness vs loop

| Layer | Loads | Who decides | Example |
|---|---|---|---|
| Context | Every run | Always on | `AGENTS.md`: provider pins, naming, never-do list |
| Skill | On demand, if matched | The agent, voluntarily | `SKILL.md`: house convention for a task type |
| Harness | Every run, enforced | The system, not the agent | A hook that blocks `apply` without a clean plan |
| Loop | Across runs | What re-triggers, when it stops | A schedule, a webhook, a stopping condition |

## Prose skill vs skill with a bundled script

| | Prose-only skill | Skill with a bundled script |
|---|---|---|
| Carries | Judgment rules ("NAT gateway per AZ in prod") | Judgment rules AND computable facts |
| Enforcement | Agent reads it, reasons, can still misjudge | The script exits 0 or 1, no reasoning involved |
| Example, this module | `terraform-module-conventions`: pins, tags, secrets | `vpc-environment-scaffold`: design rules in prose, CIDR overlap in `scripts/check_cidr_overlap.py` |
| Still voluntary | Yes, an agent can skip the whole skill | Yes, same voluntary limit, the script only runs if the agent reaches for the skill at all |

A bundled script closes the "did the agent get the arithmetic right" gap. It does not close
the "did the agent decide to use this skill at all" gap, that's still the harness's job, M06
and M08.

## This module's lab, in one line

Part I: same intent, same agent, skill absent vs skill present: provider pin, required tags,
and a hardcoded secret all get fixed on the first try, once the skill exists and its
description is specific enough to trigger. Part II: a skill bundling a real overlap-checker
script catches a genuine CIDR collision across three materially different VPC environments,
dev, staging, and prod, before `terraform apply` ever runs.
