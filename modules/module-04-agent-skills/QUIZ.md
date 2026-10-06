# M04 Quiz: Agent Skills for IaC

9 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. A team writes an `AGENTS.md` with provider pins and naming rules, always loaded, and
separately a `SKILL.md` for generating Terraform modules, loaded only when that specific
task comes up. What's the actual distinction between the two?**

- A. `AGENTS.md` is for humans, `SKILL.md` is for agents
- B. Context (`AGENTS.md`) is always loaded; a skill is loaded only when a task matches it
- C. There is no real distinction, they're interchangeable
- D. `SKILL.md` is only for Docker, `AGENTS.md` is only for Terraform

<details>
<summary>Answer</summary>

**B.** Context is standing information true on every single run, whether or not the
current task needs all of it. A skill is packaged capability an agent reaches for only
when a task actually matches, not loaded by default.

</details>

---

**2. A skill's `description` field reads "Terraform best practices." The team is confused
why the agent never seems to use it. What's the most likely cause?**

- A. The skill is too short
- B. The `description` is too vague to match against a specific task, so the agent has
  nothing concrete to trigger on
- C. Skills only work with YAML version 2
- D. The skill needs to be renamed to `SKILL.yaml`

<details>
<summary>Answer</summary>

**B.** The `description` field is the matching key an agent checks a task against. A vague
description like "Terraform best practices" gives the agent nothing specific to match,
so the skill sits there, correct, unused.

</details>

---

**3. Which of these is something a skill CAN do, that it inherently CANNOT do compared to a
harness gate?**

- A. Suggest a convention to an agent that's already inclined to look for it
- B. Block an action outright, regardless of what the agent decides
- C. Live in a `.claude/skills/` directory
- D. Have a YAML frontmatter

<details>
<summary>Answer</summary>

**B.** A skill is voluntary: an agent can misjudge a match, not have it loaded, or simply
choose not to reach for it. It can only ever suggest. A harness gate runs and can block an
action whether or not the agent wants it to, that's a different, stronger guarantee.

</details>

---

**4. In this module's lab, the same one-line intent is handed to the same agent twice, once
with the `terraform-module-conventions` skill available, once without. What autonomy step
does this lab sit on?**

- A. Step 1, suggest
- B. Step 3, propose with plan, because the agent proposes code and a plan, and a human
  still reads both before anything runs
- C. Step 5, supervised, because the agent runs the loop on its own
- D. Step 6, unattended

<details>
<summary>Answer</summary>

**B.** The skill changes what gets proposed, not who is reading the plan before `apply`
runs. A better proposal is not more autonomy. That's still step 3.

</details>

---

**5. In the lab, checkov's secrets framework goes from failing to clean between run 1 and
run 2, but checkov's terraform framework still reports the same S3-hardening findings in
both runs. Why doesn't the skill fix those too?**

- A. The skill is broken
- B. Checkov doesn't check S3 buckets at all
- C. The skill was scoped to provider pins, tags, and secrets only, general S3 hardening is
   a systematic scanning job, covered later in M09
- D. Floci doesn't support encrypted buckets

<details>
<summary>Answer</summary>

**C.** A skill fixes exactly what it says it fixes. This one names three rules: pins, tags,
secrets. Broad infrastructure posture, encryption, versioning, logging, needs the
systematic scanners M09 covers, not a single skill invoked once.

</details>

---

**6. A team wants a rule enforced no matter what an agent decides, even if the agent never
reaches for any skill at all. What should they reach for instead of a skill?**

- A. A longer `description` field
- B. A harness gate or hook, covered in M06 and M08
- C. A second `AGENTS.md`
- D. Nothing, skills already guarantee this

<details>
<summary>Answer</summary>

**B.** A skill only ever suggests, voluntarily, to an agent already inclined to look for
it. Something enforced regardless of the agent's own decision is a harness-layer job, a
hook or gate, not a skill.

</details>

---

**7. What is `demos/m1-agent-preview/.claude/skills/container-conventions/SKILL.md` used
for in this module?**

- A. It's duplicated into this module as a new copy
- B. It's the worked example the lab reads first, before writing a new skill for the
  Terraform/Floci case
- C. It's deprecated and replaced by this module's skill
- D. It only applies to Kubernetes work

<details>
<summary>Answer</summary>

**B.** It's referenced as a real, already-verified example, not duplicated. This module's
lab writes a new skill, `terraform-module-conventions`, for a different task type.

</details>

---

**8. Part II's `vpc-environment-scaffold` skill bundles a real Python script that checks
whether two environments' CIDR blocks overlap. Why is a bundled script a better fit here
than another paragraph of prose telling the agent to "check for CIDR overlaps"?**

- A. Scripts are always better than prose, in every case
- B. Whether two CIDR blocks overlap has one correct answer, computable with plain
  `ipaddress` arithmetic, not a judgment call an agent might get wrong on a bad day
- C. Python is faster than English to read
- D. Prose skills can't have a `description` field

<details>
<summary>Answer</summary>

**B.** The test isn't "is code fancier than prose," it's whether the rule is a judgment call
or a computable fact. A CIDR overlap has one right answer. A script that computes it and
returns a real exit code closes the gap that prose alone leaves open: the agent trying its
best versus the answer actually being checked.

</details>

---

**9. In Part II's lab, dev and staging both use `nat_strategy = "single"`, but prod uses
`nat_strategy = "per_az"`, one NAT gateway per availability zone. Which layer decided that,
and could the bundled overlap-checker script have caught it if someone got it backwards?**

- A. The overlap checker would catch it, NAT strategy is also arithmetic
- B. It's a design judgment written into the skill's prose, not something the bundled
  script checks. The script only verifies CIDR non-overlap
- C. Floci enforces NAT strategy automatically, no decision needed
- D. Both are handled by Terraform's own built-in validation

<details>
<summary>Answer</summary>

**B.** A single skill can carry both kinds of rule at once, arithmetic a script verifies and
judgment written as prose the agent has to reason about. Confusing the two, assuming
something is checked because it lives in a skill file, is the exact mistake to watch for
once a skill starts bundling real code.

</details>
