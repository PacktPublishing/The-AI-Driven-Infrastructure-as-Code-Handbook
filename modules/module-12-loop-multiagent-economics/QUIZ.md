# M12 Quiz: Loop Engineering, Multi-Agent Ops, Economics

7 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. Which of the following is a real, machine-checkable stopping condition?**

- A. "Stop when the infrastructure looks stable"
- B. "Stop when terraform plan shows zero changes and checkov exits clean"
- C. "Stop when the team feels confident"
- D. "Stop after a reasonable amount of time"

<details>
<summary>Answer</summary>

**B.** A stopping condition has to be something a machine can check without asking a human, an
exact rule, not a feeling. A, C, and D all require a person to judge whether the loop should
stop, which defeats the point of a loop in the first place.

</details>

---

**2. A script runs a fixed sequence of Terraform commands once, produces useful output, and exits. Is this a loop?**

- A. Yes, because it did real work
- B. No, it has neither a trigger to re-run it nor a stopping condition, it's a single run
- C. Yes, as long as it ran more than one command
- D. No, because it didn't touch a real cloud account

<details>
<summary>Answer</summary>

**B.** A loop needs both a trigger, what re-invokes it, and a stopping condition, when it quits.
A single run with neither isn't a loop, it's a script that happened to run once. Whether it did
useful work (A) or touched a cloud account (D) has nothing to do with whether it's a loop.

</details>

---

**3. What has to already be true before step 6, unattended, is safe to attempt?**

- A. The team has used AI tools for at least six months
- B. A complete harness (context, skills, hooks, verification) is already in place, catching the mistakes a human would catch
- C. The agent has a large enough context window
- D. Nothing, step 6 is safe by default once a stopping condition exists

<details>
<summary>Answer</summary>

**B.** A loop on top of a broken harness just repeats the harness's mistakes faster. Step 6 only
makes sense once the harness underneath it (built in modules 4 through 8) is already catching
what a human reviewer would have caught. Team tenure (A) and context window size (C) aren't the
precondition, and D is the exact mistake this module warns against.

</details>

---

**4. What is the real difference between step 5 (supervised autonomy) and step 6 (unattended)?**

- A. Step 6 uses a bigger model
- B. Step 5, a human reviews every outcome; step 6, a human reviews only exceptions
- C. Step 5 requires a cloud account, step 6 doesn't
- D. There is no real difference, they're the same step under different names

<details>
<summary>Answer</summary>

**B.** Step 5 means a human checks the result of every run. Step 6 means a human is only pulled
in when something actually goes wrong, an exception, not a routine check. That's the entire
distinction, and it's a meaningful one.

</details>

---

**5. Claude Code teams and Hermes are both mentioned in this module. What's the actual distinction this course draws between them?**

- A. Claude Code teams is the real, usable tool taught here; Hermes is named once as a reference point for where multi-agent orchestration is headed, and isn't taught in this course
- B. They are two names for the exact same tool
- C. Hermes is taught in depth in this module, Claude Code teams is only mentioned in passing
- D. Both are retired tools this course explicitly avoids

<details>
<summary>Answer</summary>

**A.** Claude Code teams is the concrete, usable example this course actually works with. Hermes
gets named once, deliberately, as a pointer to where the field is headed, not as course content.

</details>

---

**6. A tool advertises 60 to 90 percent savings on token usage. What does this module say you should do with that claim?**

- A. Trust it, vendors have no reason to round favorably
- B. Treat it the same way you'd treat any unverified vendor statistic: look for an independent, measured number before relying on it
- C. Ignore token cost entirely, it doesn't matter for infrastructure work
- D. Assume the real number is even higher than advertised

<details>
<summary>Answer</summary>

**B.** The real, measured comparison in this course found roughly 8.5 percent savings for one
such tool, and an actual cost *increase* for another (rtk, at low reasoning effort), against
advertised figures of 60 to 90 percent. Vendor claims about token savings deserve the same
fact-discipline as any other statistic in this course, not automatic trust (A) and not automatic
suspicion in the other direction (D).

</details>

---

**7. Put the six steps of the autonomy ladder in order, from least to most autonomous.**

- A. Suggest, draft, propose with plan, gated apply, supervised autonomy, unattended
- B. Draft, suggest, gated apply, propose with plan, unattended, supervised autonomy
- C. Unattended, supervised autonomy, gated apply, propose with plan, draft, suggest
- D. Suggest, propose with plan, draft, gated apply, unattended, supervised autonomy

<details>
<summary>Answer</summary>

**A.** Suggest (the agent proposes text, a human types it), draft (the agent writes files, a
human reads every line), propose with plan (code and a plan together), gated apply (automated
checks plus human approval), supervised autonomy (the agent loops, a human reviews outcomes),
unattended (a human reviews only exceptions). B and D swap steps out of order, C reverses the
whole ladder.

</details>
