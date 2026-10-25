# M12 Quiz: Loop Engineering for Infrastructure Agents

10 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. A team schedules a job that runs an agent every night with the same request. Which of the
six parts of a loop is it missing?**

- A. The trigger
- B. The work
- C. The verifier, and with it the stop rules
- D. The state

<details>
<summary>Answer</summary>

**C.** The schedule is the trigger and the agent is the work. Nothing answers "is the job done?"
with a yes or a no, so nothing decides whether to stop, go again, or call a human. The six parts
are trigger, work, verifier, stop rules, budget and state. A real loop has all six, every time.

</details>

---

**2. `/goal` uses a separate small model to judge whether the condition holds. What can that
model see?**

- A. The files on disk and the scanner output it runs itself
- B. Only the conversation: what the agent chose to show in the transcript
- C. The git history of the repository
- D. Everything the agent can see, including tool results it did not print

<details>
<summary>Answer</summary>

**B.** The documentation says the evaluator "doesn't run commands or read files independently".
It is a real improvement over a completion phrase, because the judge is not the model that did
the work. But a transcript that says "checkov passes" is a claim about the scanner, not a run of it.

</details>

---

**3. Why does this module's Stop gate throw its JSON input away?**

- A. The input is too large to parse in Bash
- B. It decides from the working copy and the scanner, not from the transcript
- C. Codex sends no input to Stop hooks
- D. To save tokens

<details>
<summary>Answer</summary>

**B.** `stop-gate.sh` reads its input and discards it, then runs `loop/verify.sh` against the
repository. That is the whole difference from `/goal`: the evaluator there receives the
conversation, ours receives a working copy and a scanner. The agent cannot talk its way past an
exit code.

</details>

---

**4. A `codex exec` run finished, the agent said the work was done, and `.loop/state.md` does not
exist. What most likely happened?**

- A. The verifier returned no verdict
- B. The gate passed and forgot to write the file
- C. The hooks were never trusted, so Codex skipped them without a word
- D. The budget ran out

<details>
<summary>Answer</summary>

**C.** Codex runs a project hook only after someone trusts it with `/hooks`, and in
non-interactive mode it skips an untrusted one silently. The gate writes a line to the state file
on every outcome, including no verdict and budget exhausted, so an empty state file means the gate
never ran. A gate that does not run looks exactly like a gate that passed, unless the loop writes
down what it decided.

</details>

---

**5. `verify.sh` exits 2 because `checkov` is not on PATH. What should the Stop gate do?**

- A. Send the agent back to work, the same as a failed check
- B. Treat it as done, since nothing failed
- C. Let the session end and record "no verdict" for a human
- D. Retry until the budget runs out

<details>
<summary>Answer</summary>

**C.** The three outcomes are done, not done and no verdict. Sending an agent back to fix a
broken scanner it cannot see is a loop with no exit, and treating a scan that did not run as clean
is worse. The gate lets the session end and records the fact in `.loop/state.md`.

</details>

---

**6. An agent adds a `# checkov:skip=CKV_SECRET_2` comment and Checkov stops reporting the
finding. What does `verify.sh` say?**

- A. DONE, because Checkov reports no failed checks
- B. NOT DONE, because a suppression is not a fix
- C. NO VERDICT, because the scan was altered
- D. It depends on the Checkov version

<details>
<summary>Answer</summary>

**B.** An agent told "make the scan pass" can reach for a suppression. The verifier checks for
any `checkov:skip` comment before it runs the scan and returns not done, naming the line. The fix
is to fix the finding, not to hide it.

</details>

---

**7. When is a maker and checker topology worth its cost for an infrastructure change?**

- A. Always, because two models are safer than one
- B. When the question needs judgment a script cannot answer, such as whether a module is
  structured the way the team structures modules
- C. When the scanner is slow
- D. When the pieces of the job are independent

<details>
<summary>Answer</summary>

**B.** Use the checker for judgment and keep the gate for facts. A second model agreeing that a
scan passed is still not a scan. Independent pieces with wall-clock time as the bottleneck are the
case for fan-out on worktrees, not for a checker. Everything else stays one agent and a gate.

</details>

---

**8. What did JetBrains' July 2026 paired A/B benchmark find for the rtk command rewriter at low
reasoning effort?**

- A. A 60 to 90 percent saving, as advertised
- B. An 8.5% saving
- C. Each task was about 7.6% more expensive, across 80 clean pairs
- D. No measurable difference

<details>
<summary>Answer</summary>

**C.** rtk advertises 60 to 90 percent. Measured on Claude Code against the SkillsBench task set,
it made each task about 7.6% more expensive at low effort and made no measurable difference at
high effort. The 8.5% saving is the caveman skill, which advertises 65 percent. Task quality did
not change in either arm. Quote the date, the setup and the sample size with the number.

</details>

---

**9. Why is `/loop` the wrong primitive for a nightly compliance control?**

- A. It cannot run Checkov
- B. It lives inside an open session: close the terminal and it stops, and recurring tasks expire
  after seven days
- C. It only runs in Codex
- D. It has no way to fix what it finds

<details>
<summary>Answer</summary>

**B.** `/loop` is the right tool for watching a build while you work. A control that has to run on
the nights nobody is at a desk needs a schedule with no session open: routines, Desktop tasks or
GitHub Actions in Claude Code, automations or GitHub Actions in Codex. The lab's nightly example is
an Actions workflow that runs the same gated session and judges the job by the state file.

</details>

---

**10. A team says "we have a loop now, so we can run it unattended." What has to be true first?**

- A. The loop has run successfully once
- B. A gate (Module 6), a workflow harness that makes the agent plan, test first and show evidence
  (Module 8), and a real pipeline (Module 9) are all in place underneath it
- C. The agent is the newest model
- D. The budget is set to eight

<details>
<summary>Answer</summary>

**B.** At step 6 no human approves each run, and a person appears only on an exception: budget
exhausted or no verdict. Without all three, "unattended" just means "unsupervised". That is not a
step up the ladder. It is a step off the edge of it. The course teaches what has to be true and
leaves the decision, task by task, to the team.

</details>
