# M04 Projects: Agent Skills for IaC

Stretch projects, hints not solutions. Pick one, or all four.

## 1. Write a skill for your own team's convention

Take one rule your team already enforces by hand in code review, naming, tagging, a
required README, whatever it is, and write it as a real `SKILL.md`. Test it the same way
this module's lab did: same intent, skill absent vs skill present, real diff.

*Hint: the hardest part is usually the `description` field, not the body. Write it last,
after you know exactly what should trigger the skill.*

## 2. Break discoverability on purpose

Take a working skill, yours or `terraform-module-conventions` from this module's lab, and
rewrite its `description` to be vague. Run the same intent again. Does the skill still get
used?

*Hint: try a few points along the spectrum, from very specific to very vague, and note
where it stops triggering reliably.*

## 3. Skill vs hook

Pick one rule from a skill you've written and reimplement it as a pre-commit hook or a CI
check instead. Compare the two: which one only suggests the right behavior, and which one
actually stops a violation from landing?

*Hint: you'll need M06's guardrails material for the hook side of this, this project is a
good reason to come back to it after that module.*

## 4. Extend the VPC scaffolder skill with a second bundled script

Part II's `vpc-environment-scaffold` skill ships one deterministic script, a CIDR overlap
checker. Add a second one: a generator that scaffolds a brand new environment directory
(`main.tf`, `variables.tf`, `provider.tf`, `terraform.tfvars`) from the shared module, given
just a name, an AZ count, and a `nat_strategy`, instead of a human copy-pasting an existing
environment and editing five values by hand.

*Hint: the generator's job is to produce files identical in structure to `vpc/envs/dev` or
`vpc/envs/prod`, not to invent a new structure. Diff its output against a hand-written
environment to prove it.*
