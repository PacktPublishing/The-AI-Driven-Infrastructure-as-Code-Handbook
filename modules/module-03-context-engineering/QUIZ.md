# M03 Quiz: Context Engineering for Infrastructure

10 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. A team says: "Our agent writes correct Terraform for simple modules, but every time we ask it to follow our internal naming convention or use our approved module registry, it ignores the instruction." Which of the three layers does this point to?**

- A. Context
- B. Harness
- C. Loop

<details>
<summary>Answer</summary>

**A, context.** Wait, this looks like the M01 harness example, but read it again: the
agent "ignores" a naming convention it may never have been given at all is different
from an agent that knows a rule and skips it under pressure. If the convention was
never written down anywhere the agent could read it, the fix is context: write it
down. If the agent has read the rule and still skips it, that is harness. This
question tests whether you can tell the two apart, not just recall the M01 mapping.

</details>

---

**2. Which belongs in an `AGENTS.md`, and which belongs in a one-off prompt: "build me a VPC with two subnets" vs "secrets are always `sensitive`, never a `default`"?**

- A. Both belong in `AGENTS.md`
- B. "build me a VPC" belongs in `AGENTS.md`, the secrets rule belongs in a prompt
- C. "build me a VPC" is a prompt, the secrets rule belongs in `AGENTS.md`
- D. Neither belongs in either

<details>
<summary>Answer</summary>

**C.** "Build me a VPC with two subnets" is a one-off ask, true for this task only. "Secrets are
always `sensitive`" is true on every task, for every module, forever, until the team changes
its mind. That is exactly the test for what belongs in standing context versus a prompt.

</details>

---

**3. In the information-gap finding cited in this module, how many of the residual policy failures were resolved once policy text was made visible to the agent?**

- A. 79% of them
- B. 11 of 14
- C. All of them
- D. None, visibility didn't help

<details>
<summary>Answer</summary>

**B, 11 of 14.** Quote the fraction, not a rounded percentage, it's a small sample and the
exact numbers matter more than a tidy-looking percent. The 3 that remained were not fixed
by visibility alone, a reminder that context closes most of the gap, not all of it.

</details>

---

**4. Why does repo layout affect what an agent retrieves?**

- A. Agents have a hidden channel that reads a repo's true intent, independent of file names
- B. An agent finds files the same way a human does, mostly by name and path, so a confusingly organized repo confuses the agent the same way it would confuse a new hire
- C. Repo layout only matters for very large repos, over 10,000 files
- D. It doesn't, retrieval is random regardless of repo layout

<details>
<summary>Answer</summary>

**B.** There is no hidden channel. If a human engineer would struggle to find the right file
in your repo, an agent will struggle too, because it is following the same names and paths a
human would follow.

</details>

---

**5. A learner writes an `AGENTS.md` that says only: "Follow best practices." Is this good context engineering?**

- A. Yes, "best practices" covers everything
- B. No, it's too vague to act on. Good context is specific and checkable, like "secrets are always `sensitive`, never a `default`", not a general aspiration
- C. Yes, as long as the file exists at all
- D. No, because `AGENTS.md` files should never contain the word "practices"

<details>
<summary>Answer</summary>

**B.** "Follow best practices" gives an agent nothing to actually check its own output
against. The AGENTS.md examples in this module, provider pins, a naming convention, a
never-do list, are specific enough that a violation is obvious on sight.

</details>

---

**6. In the lab, the exact same intent was run twice, same agent, same repo. What was the only thing that changed between run 1 and run 2?**

- A. The agent's model version
- B. Whether an `AGENTS.md` file was present in the repo
- C. The intent itself was reworded to be clearer
- D. A more powerful stopping condition was added

<details>
<summary>Answer</summary>

**B.** That is the entire point of the before/after test: hold everything else constant,
change one variable, the presence of written context, and read the diff. Everything else,
same agent, same repo, same intent, stayed fixed on purpose.

</details>

---

**7. Which of these is a context problem, and which needs a harness gate instead: (1) an agent hardcodes a secret because nobody wrote down the rule against it, (2) an agent knows the rule against hardcoding secrets but does it anyway because it's the fastest way to finish under a deadline?**

- A. Both are context problems
- B. (1) is context, fixed by writing the rule down. (2) is not, the agent already knew the rule and skipped it anyway, which needs an enforced gate, not a file
- C. Both need a harness gate
- D. Neither is fixable, some mistakes are just unavoidable

<details>
<summary>Answer</summary>

**B.** A context problem is missing information. Once the information exists and the
mistake still happens, more context will not fix it, only an automated check that makes
the shortcut impossible will. That's the seam into M06.

</details>

---

**8. This module's lab measured plain `checkov -d .` against `checkov -d . --compact --quiet` on the same 21-resource module. What actually got smaller?**

- A. The number of findings, compact hides some real failures
- B. The output size, ~85% smaller, same 25 findings either way, just without every passed check and repeated source excerpt
- C. The scan time, compact skips checks to run faster
- D. Nothing measurable changed, `--compact` is only a display preference

<details>
<summary>Answer</summary>

**B.** Same scan, same 25 failed checks. The plain run also prints all 60 passed checks and
repeats the offending source lines under every failure. Compact drops both and keeps only
what changed. That's Reduce: filtering noise at the input, not hiding real findings.

</details>

---

**9. Which discipline does `checkov --compact` belong to, and which does a written `AGENTS.md` belong to?**

- A. Both are Retain, they're both about writing things down
- B. `--compact` is Retain, `AGENTS.md` is Route
- C. `--compact` is Reduce, filtering what enters the window. `AGENTS.md` is Retain, standing facts that survive a reset
- D. Both are Route, they both live on disk

<details>
<summary>Answer</summary>

**C.** Reduce is about what you let in, filtering a noisy tool's raw output before it ever
reaches the window. Retain is about what survives a reset, standing facts an agent reads
every session instead of re-guessing. Different questions, different fixes.

</details>

---

**10. In the lab's Route exercise, a brand new session with zero conversation history was asked to read `STATE.md` and finish the task. Why did it work?**

- A. The agent remembered the earlier session automatically
- B. The plan and the decision were written to a file on disk, so the new session never needed memory of the earlier conversation, it only needed to read
- C. It didn't actually work, the example is aspirational
- D. `--permission-mode plan` made the agent recall past sessions

<details>
<summary>Answer</summary>

**B.** That's the entire point of Route. The new session had no memory and needed none,
because nothing it needed to know was ever only in the conversation. A conversation you
clear is gone. A file on disk is still there for any session, including one that has
never seen this task before, to read and continue correctly.

</details>
