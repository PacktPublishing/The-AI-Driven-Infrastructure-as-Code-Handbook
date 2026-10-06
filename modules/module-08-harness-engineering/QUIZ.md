# M08 Quiz: Harness Engineering

9 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. What is a "harness," as this course uses the word?**

- A. Any single skill file written for an agent
- B. A skill, an MCP server, and a hook assembled around one real discipline
- C. A synonym for the agent itself
- D. A cloud account used only for testing

<details>
<summary>Answer</summary>

**B.** A harness is what you get when the pieces taught separately in M04 through M06 (a skill, an
MCP server, a hook) are assembled around one discipline, not three unrelated tools sitting next to
each other in a repo.

</details>

---

**2. A team says: "Our agent understands the task fine, it just keeps ignoring our tagging
convention." Which layer does this symptom point to?**

- A. Context
- B. Harness
- C. Loop

<details>
<summary>Answer</summary>

**B, harness.** "Can't get one task right at all" would be context. "Ignores our standards" is the
harness symptom from M01's diagnostic, this module's whole subject.

</details>

---

**3. A hook script checks a response for the phrase "tests pass" and, if found, requires a real
pass/fail count nearby before letting the claim stand. What discipline does this hook enforce?**

- A. Test-first
- B. Verification-before-claiming
- C. Root-cause debugging
- D. Blast radius

<details>
<summary>Answer</summary>

**B.** The hook doesn't care whether a test was written first, it checks whether a completion
claim has real evidence attached before it's accepted. That's verification-before-claiming.

</details>

---

**4. Which of these is NOT one of the three superpowers disciplines this module covers?**

- A. Test-first
- B. Verification-before-claiming
- C. Root-cause debugging
- D. Cost estimation before apply

<details>
<summary>Answer</summary>

**D.** Cost estimation is M09's subject (Infracost as a gate). The three disciplines here are
test-first, verification-before-claiming, and root-cause debugging.

</details>

---

**5. Two runs of the same agent both say "checkov passes." Run 1 gets blocked by a hook, run 2
doesn't. What's the most likely difference between the two runs?**

- A. Run 2 used a more expensive model
- B. Run 2's response had real command output backing the claim, run 1's didn't
- C. Run 1 ran on a Monday
- D. Run 2 was reviewed by a human first

<details>
<summary>Answer</summary>

**B.** The hook checks for evidence next to the claim, not the confidence of the wording or which
model produced it. Same claim, same words, the only real difference is whether the evidence was
actually there.

</details>

---

**6. Why does the course's own rule say "never add a loop on top of a broken harness"?**

- A. Loops are always slower than manual work
- B. A loop just repeats a broken harness's mistakes faster, with less human attention each time
- C. Loops are not supported by most agent tools
- D. Harnesses and loops solve the same problem, so only one is needed

<details>
<summary>Answer</summary>

**B.** Module 12's step 5, supervised autonomy, means a human reviews outcomes rather than every
step. That only works if the harness underneath is actually catching mistakes, otherwise the loop
just makes the same unbacked claims faster and harder to notice.

</details>

---

**7. A skill states "never claim a check passed without pasting real output." No hook exists to
check this. What's true about this rule?**

- A. It's a complete harness on its own
- B. It's words the agent reads, useful but not enforced, exactly the kind of thing that gets skipped under time pressure
- C. It's equivalent to a gate from M06
- D. It automatically becomes a hook once written down

<details>
<summary>Answer</summary>

**B.** A skill can only ever suggest. Without a hook enforcing it mechanically, the rule survives
only as long as the agent happens to follow it carefully, which is precisely the failure mode this
module exists to fix.

</details>

---

**8. In this module's lab, a test for `CKV_AWS_145` (S3 default encryption) is written and run
BEFORE the fix exists. What is the correct next step, per the test-first discipline?**

- A. Immediately write the fix, the test doesn't need to actually fail first
- B. Confirm the test fails, and fails for the right reason (the check is genuinely missing), before writing any fix
- C. Skip running it, since it's obvious the bucket isn't encrypted yet
- D. Write the test and the fix in the same commit, order doesn't matter

<details>
<summary>Answer</summary>

**B.** "Verify RED" is not optional. A test that fails for the wrong reason, a typo, a missing
file, proves nothing about the real behavior you're about to build. This lab's RED run showed the
actual `CKV_AWS_145` finding, confirming the failure was real before a single line of fix was
written.

</details>

---

**9. This module's debugging exercise runs three real, plausible fix attempts against a broken
`endpoint_url` provider argument, all three fail with the same error. What does the 3-Fix Rule say
to do next?**

- A. Try a fourth, more creative guess
- B. Stop guessing and question the architecture, compare against a known-working example instead
- C. Revert all three attempts and give up on the task
- D. Ship it with the error still present, it's probably cosmetic

<details>
<summary>Answer</summary>

**B.** Three failed attempts on the same symptom is evidence, not bad luck, it means the fixes are
aimed at the wrong layer. This lab's real root cause only surfaced by comparing the broken config
against the course's own known-working provider stub: `endpoint_url` was never valid AWS-provider
syntax, no version pin or cache wipe could have touched it.

</details>
