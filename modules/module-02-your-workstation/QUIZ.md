# M02 Quiz: Your Agentic IaC Workstation

9 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. Why does this course teach both Claude Code and Codex CLI instead of picking one?**

- A. Because one of them will be discontinued soon
- B. Because a team that standardizes on one tool still needs to read code the other tool
  produced, and the underlying loop transfers between both
- C. Because Codex CLI is required for Tier 1 labs
- D. Because Claude Code cannot run Terraform

<details>
<summary>Answer</summary>

**B.** Both tools run the same core loop from module 1: intent, act, observe, decide, repeat,
stop. Teaching only one CLI would teach that CLI's quirks instead of the loop underneath it,
and the loop is what actually transfers to a different tool later.

</details>

---

**2. Why does this course have you install Terraform, Checkov, and Trivy at exact pinned
versions instead of "whatever's newest"?**

- A. Newer versions cost money
- B. Every `[ Expected output ]` block in this course was captured from a real run against
  those exact versions, so a different version on your machine can genuinely produce
  different output
- C. Pinned versions run faster than the latest release
- D. Older tool versions are required for Docker to work at all

<details>
<summary>Answer</summary>

**B.** Pinned tool versions mean "it works on my machine" isn't a debugging step, it's a bug,
because your machine is running the exact versions the course's captured output came from.

</details>

---

**3. An agent proposes Terraform as chat text only, and a human types it into the file by
hand. Which step on the autonomy ladder is this?**

- A. Step 1, suggest
- B. Step 2, draft
- C. Step 3, propose with plan
- D. Step 4, gated apply

<details>
<summary>Answer</summary>

**A, step 1, suggest.** The agent never touches a file. Every keystroke that lands in the repo
is the human's, even though the words came from the agent.

</details>

---

**4. An agent writes `main.tf` directly to disk, and a human reads it before running anything.
Which step is this?**

- A. Step 1, suggest
- B. Step 2, draft
- C. Step 5, supervised
- D. Step 6, unattended

<details>
<summary>Answer</summary>

**B, step 2, draft.** The difference from step 1 isn't "more trust," it's a different kind of
control: from typing every character yourself to reading every line before it runs.

</details>

---

**5. In this module's own real, captured run, the same one-line intent, run twice through the
same agent, produced two different Terraform designs. What does that tell you?**

- A. The agent made a mistake and one of the two runs is wrong
- B. Each session starts cold with no memory of a prior run, so reading every line every time
  matters, not just on the first run
- C. This only happens with Codex, never with Claude Code
- D. It means one of the two Terraform versions is misconfigured

<details>
<summary>Answer</summary>

**B.** Unless something gives an agent memory of a prior session on purpose, nothing carries
over. Two runs of the same ask can both be individually reasonable and still diverge. The
only way to catch that is to actually read what came back, every time.

</details>

---

**6. What's in `CLAUDE.md` and `AGENTS.md` at the end of this module?**

- A. Full provider pins and naming conventions
- B. A list of every skill available to the agent
- C. Nothing yet, they're empty, real content goes in during module 3
- D. The learner's personal API keys

<details>
<summary>Answer</summary>

**C.** This module only shows where each tool's standing-context file lives. Writing real
content into them, provider pins, conventions, the never-do list, is module 3's subject,
context engineering.

</details>

---

**7. This module's own lab found a real bug: two independent agent sessions both wrote a
`docker_container` volume `host_path` that referenced `path.module` without wrapping it in
`abspath()`. `terraform validate` passed both times. What does that actually prove?**

- A. `terraform validate` is broken and shouldn't be trusted at all
- B. `terraform validate` checks syntax and types, not every constraint a provider enforces once
  it plans a real change, so a clean validate is not the same as a clean plan
- C. The bug only exists because Docker is misconfigured
- D. `abspath()` is optional, the module would have applied fine either way

<details>
<summary>Answer</summary>

**B.** `terraform plan` caught what `validate` couldn't: the docker provider rejects a relative
`host_path` once it actually has to act on it. Both real runs validated clean and both would
still have failed the moment anyone tried to plan or apply them.

</details>

---

**8. In the lab's `acceptEdits` step, you asked a subagent to run `checkov` and check for the
`abspath()` pattern. The subagent's `checkov` call got blocked by its own tool permissions, and
it told you to run it yourself instead of guessing. Why is that the right behavior, not a bug?**

- A. Subagents should always have every permission the parent session has
- B. A subagent's narrower permission surface, and reporting a block honestly instead of
  fabricating a result, is exactly the isolation a bounded delegated task should have
- C. It's a bug, the subagent should have used `--dangerously-skip-permissions`
- D. Subagents can never run Bash commands under any configuration

<details>
<summary>Answer</summary>

**B.** Delegating to a subagent is meant to bound what a task can touch, not hand it a blank
check on your own permissions. Reporting a block honestly, instead of inventing a result, is the
behavior you want, and it's the same discipline module 6 turns into a formal guardrail.

</details>

---

**9. What does a custom slash command in `.claude/commands/` actually do that typing the same
prompt again doesn't?**

- A. It makes the agent smarter
- B. It turns a repeatable sequence into a fact the repo carries, checked in alongside the code
  it applies to, so anyone or any agent working in that directory gets the same checks
- C. It grants the agent extra tool permissions automatically
- D. It only works with Codex, not Claude Code

<details>
<summary>Answer</summary>

**B.** A slash command isn't a shortcut for you personally, it's a checked-in fact: `/tf-check`
runs the same `fmt`/`init`/`validate`/`plan` sequence for anyone who opens this repo, the same
way `AGENTS.md` carries a rule instead of a person carrying it in their head.

</details>

