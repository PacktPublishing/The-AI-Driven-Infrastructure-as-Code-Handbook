# M06 Quiz: Guardrails: Permissions, Hooks, Blast Radius

9 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. What's the real difference between a skill (M04) and a hook (this module)?**

- A. A skill is written in YAML, a hook is written in bash
- B. A skill is voluntary, the agent decides whether to use it; a hook runs regardless, every time
- C. A skill is for reading files, a hook is for writing them
- D. There's no real difference, they're two names for the same thing

<details>
<summary>Answer</summary>

**B.** An agent can skip a skill with a vague description, or simply not reach for it. A hook
wired into the pipeline runs on every attempt, whether or not the agent wants it to.

</details>

---

**2. A `terraform plan -json` shows one resource change: `aws_s3_bucket.reports`, action
`create`. Default policy (block-on-delete on, max-resources 5, high-radius types
`aws_vpc,aws_iam_policy,aws_iam_role`). Does the gate block it?**

- A. Yes, any new bucket is risky
- B. No, it passes: no delete, under the resource limit, not a high-radius type
- C. Yes, because S3 buckets are always high-radius
- D. The gate can't evaluate a plan with only one resource

<details>
<summary>Answer</summary>

**B.** All three checks come back clean: zero deletes, one resource under the limit of five, and
`aws_s3_bucket` isn't on the high-radius list. The gate has nothing to block.

</details>

---

**3. A pre-`apply` script finds a hardcoded secret, prints a red warning, and then lets `apply`
run anyway. Is this a gate?**

- A. Yes, it caught the problem, that's what matters
- B. No. A gate has to actually stop the action; a check that warns and continues is a suggestion with better formatting
- C. Yes, as long as the message is clear enough
- D. It depends on how the secret was formatted

<details>
<summary>Answer</summary>

**B.** The defining property of a gate is that its caller stops when it fails. Printing a warning
and continuing anyway means nothing downstream actually changed, the risky action still happens.

</details>

---

**4. Which of these is a mechanical blast-radius check a hook can run without understanding what any specific resource is for?**

- A. Whether the Terraform code follows the team's naming convention
- B. Whether a `delete` action appears anywhere in the plan
- C. Whether the S3 bucket name is descriptive enough
- D. Whether the PR description explains the change well

<details>
<summary>Answer</summary>

**B.** A delete action, a resource count, and a resource type are all readable directly from
`terraform show -json`, with zero domain knowledge required. Naming convention, bucket
descriptiveness, and PR quality all need a human or a much smarter check, not a mechanical gate.

</details>

---

**5. A permission boundary denies `Write(shared/**)` for an agent. What question is this rule
actually answering?**

- A. "Is this specific change to `shared/` safe?"
- B. "Should the agent be anywhere near this path at all, before any change is even proposed?"
- C. "Did the agent's plan pass the blast-radius gate?"
- D. "Is this a high-radius resource type?"

<details>
<summary>Answer</summary>

**B.** A permission boundary is set before the run starts and answers a narrower, earlier
question than a hook does: not "is this change safe" but "should the agent be here at all."

</details>

---

**6. An agent, at autonomy step 4, proposes a plan. The blast-radius hook passes it (no delete,
under the resource limit, no high-radius type). Is that enough to `apply`?**

- A. Yes, an automated pass at step 4 is sufficient on its own
- B. No, step 4 is checks AND human approval together, the hook passing doesn't replace the human
- C. No, step 4 requires the agent to also pass step 5's supervision
- D. Yes, but only if the plan is under 3 resources

<details>
<summary>Answer</summary>

**B.** Step 4, gated apply, is automated checks plus human approval, together. A hook passing
means the mechanical checks are clean, it doesn't mean a human has looked at it.

</details>

---

**7. A team's gate script has correct logic, blocks deletes, blocks oversized batches, blocks
high-radius types, but the CI step that calls it ignores the script's exit code and runs `apply`
next regardless. What's the actual state of this team's guardrail?**

- A. It's a working gate, the logic is correct
- B. It's not a gate at all, a gate with the right logic and a caller that ignores its exit code isn't a gate
- C. It's a skill, not a hook
- D. It's a permission boundary

<details>
<summary>Answer</summary>

**B.** Both halves of the gate contract have to hold: the script has to exit non-zero on failure,
and the caller has to actually stop when it sees that. Correct logic wired to an ignored exit code
behaves exactly like a warning that lets `apply` run anyway.

</details>

---

**8. This module's lab's harness runs `harness/apply_with_approval.sh` on a plan with no
`.approved` marker next to it. What happens?**

- A. It applies anyway, since the plan itself looked safe
- B. It refuses outright, exit non-zero, before any agent session even starts
- C. It pauses and waits for someone to approve it interactively
- D. It applies, but logs a warning about the missing approval

<details>
<summary>Answer</summary>

**B.** `apply_with_approval.sh` checks for the marker file first and exits with a `REFUSED`
message if it's missing, the same way the mechanical gate exits non-zero on a blocked plan. No
marker, no apply, no exception for a plan that looks harmless.

</details>

---

**9. A team removes an agent's `apply` access entirely: it can only open a PR, a human merges it,
and a GitOps controller applies the merged state. Which kind of guardrail is this?**

- A. Mechanical, it's still just reading a plan
- B. Procedural, it's still a human clicking approve
- C. Structural, "can this agent apply" is never even a question the system has to answer correctly
- D. This isn't a real guardrail, it's just a deployment pipeline

<details>
<summary>Answer</summary>

**C.** A mechanical gate has to get every check right, every time. This removes the ability to
apply unreviewed in the first place, a different, stronger kind of guardrail. This module only
previews the idea, M11 builds the real GitOps pipeline behind it.

</details>
