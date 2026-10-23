# M08 Quiz: Harness Engineering

9 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. The Superpowers documentation says "installation differs by harness." Which sense of the
word is that?**

- A. The runtime harness: Claude Code, Codex, Cursor
- B. The course's HARNESS layer: skills, hooks, gates
- C. A workflow harness: a skills library plus a bootstrap
- D. A test harness

<details>
<summary>Answer</summary>

**A.** The runtime harness is the program that runs the model and provides its tools. Superpowers
installs into each one separately. The course's HARNESS layer is the middle layer of the
three-layer model, and Superpowers itself is a workflow harness, the third sense.

</details>

---

**2. Which single file, injected at session start, makes the other Superpowers skills
usable at all?**

- A. `hooks/hooks.json`
- B. `skills/using-superpowers/SKILL.md`
- C. `skills/test-driven-development/SKILL.md`
- D. `README.md`

<details>
<summary>Answer</summary>

**B.** `hooks/hooks.json` registers the hook and `hooks/session-start` runs it, but the text that
lands in the agent's context is `using-superpowers/SKILL.md`. It tells the agent that skills
exist and that it must check for one before any action. Without that injection the other skill
files are inert.

</details>

---

**3. A skill body says "dispatch a subagent" rather than naming a tool. Why?**

- A. To keep the skill short
- B. So one skill body runs unchanged on every runtime, with the real tool names kept in a per-runtime mapping file
- C. Because subagents are not supported anywhere
- D. To hide implementation details from the user

<details>
<summary>Answer</summary>

**B.** Skills name actions, not tools. The translation to Claude Code's, Codex's or Cursor's real
tool names lives in `skills/using-superpowers/references/<runtime>-tools.md`. That is what lets
the same content ship to a dozen runtimes from one repository.

</details>

---

**4. You type "Let's make the orders table production-ready" into a harnessed Claude Code
session. What is the first thing the Superpowers workflow does?**

- A. Writes the hardened resource
- B. Runs Checkov
- C. Fires `brainstorming` and asks what you actually want before building anything
- D. Creates a git worktree

<details>
<summary>Answer</summary>

**C.** Brainstorming activates before building anything. It draws out what you want and why, plays
it back, and sizes the work: a small change gets agreed in chat, a project gets a written design
document. The worktree, plan and code all come after.

</details>

---

**5. The code is HCL. What counts as RED in the test-driven-development skill's sense?**

- A. `terraform test` reporting "Reference to undeclared resource"
- B. A `terraform test` assertion that fails because the table lacks point-in-time recovery
- C. `terraform validate` passing
- D. A plan with no changes

<details>
<summary>Answer</summary>

**B.** RED is a test that fails for the reason you expect. An undeclared resource is an error, and
the skill says to fix the error and rerun until the test fails correctly. A failing assertion
against a bare table is RED for the right reason.

</details>

---

**6. Which of these makes a dangerous `terraform apply` impossible, rather than unlikely?**

- A. The `verification-before-completion` skill
- B. The `using-superpowers` bootstrap
- C. Module 6's blast-radius hook, which exits non-zero before apply
- D. A well-written `brainstorming` session

<details>
<summary>Answer</summary>

**C.** A workflow harness makes the right process very hard to skip. A gate runs whether or not
the agent read anything and can block. This course keeps both: the harness is how the agent
arrives at the pipeline with a plan, a test and evidence; the gate is what decides.

</details>

---

**7. Your team's tagging standard is written in a wiki. The agent has Superpowers loaded and
still ignores it. Which layer, and what is the fix?**

- A. Context; write a longer wiki page
- B. Harness; the standard is not in a skill the bootstrap can find, so add one with `writing-skills` and pressure-test it
- C. Loop; add a retry
- D. Model; switch to a bigger one

<details>
<summary>Answer</summary>

**B.** "Ignores our standards" is the harness symptom from Module 1. With a workflow harness
loaded it gets specific: the standard is not in a skill. `writing-skills` is the harness's own
way to add one, and it insists on testing with pressure scenarios on a subagent, not a quiz.

</details>

---

**8. A twelve-phase platform build will run across forty sessions over two months. Which tool
carries the milestone loop, and where does Superpowers sit?**

- A. Superpowers alone; it tracks milestones in a worktree
- B. GSD on top for Discuss, Plan, Execute, Verify, Ship per milestone; Superpowers underneath for the craft in each task
- C. GSD alone; it replaces Superpowers
- D. Neither; use a spreadsheet

<details>
<summary>Answer</summary>

**B.** Superpowers runs one piece of work well and keeps no state across sessions. GSD keeps
`STATE.md`, roadmaps and phase plans, and runs each step in fresh-context subagents. They stack:
GSD carries the workflow, Superpowers carries the craft.

</details>

---

**9. Why does the course's own rule say "never add a loop on top of a broken harness"?**

- A. Loops are slower than manual work
- B. A loop repeats whatever sits underneath it, faster and with less attention each time; an agent that builds before it asks and claims before it checks just does more of that
- C. Loops are not supported by most agent tools
- D. Harnesses and loops solve the same problem

<details>
<summary>Answer</summary>

**B.** Module 12's step 5 means a human reviews outcomes, not steps. That only works once the
harness under the loop catches what the human would have caught. This module is still step 4,
and it is what step 5 has to stand on.

</details>
