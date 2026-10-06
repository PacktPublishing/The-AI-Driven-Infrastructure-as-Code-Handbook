# M09 Quiz: Verifying AI-Generated Infrastructure

7 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. Trivy and Checkov are run against the same Terraform module and report different finding counts. What does this mean?**

- A. One of the two tools has a bug
- B. The module is inconsistent and should be rewritten
- C. The two tools ship different rule sets, running only one is a coverage gap
- D. Checkov's number is always the correct one to trust

<details>
<summary>Answer</summary>

**C.** Neither number is wrong. Trivy and Checkov each check their own rule set, and for
Terraform's AWS resources those rule sets only partly overlap. Running one alone is a
coverage gap, not a safety margin, run both.

</details>

---

**2. What is Conftest, running OPA policies, for that Trivy and Checkov are not?**

- A. A faster replacement for Trivy and Checkov
- B. Checking rules specific to your own organization that no generic scanner encodes
- C. A tool for estimating cloud cost
- D. A replacement for `terraform plan`

<details>
<summary>Answer</summary>

**B.** Trivy and Checkov ship generic, vendor-maintained rule sets. Neither one knows your
team's naming convention, tagging rule, or approved module registry. You write that rule
once, in Rego, and Conftest checks every plan against it.

</details>

---

**3. A team runs `infracost breakdown` once a week and reads the estimate in a Slack message. Is this a cost gate?**

- A. Yes, because the number is accurate
- B. No, a gate has to be able to actually stop the pipeline, a report that gets read is not enforcement
- C. Yes, as long as someone reads it before Friday
- D. No, because Infracost cannot produce accurate estimates

<details>
<summary>Answer</summary>

**B.** A report that a human might read is not the same as a check wired to fail the
pipeline past a real threshold. The plan that quietly adds three oversized instances should
stop at the same gate as a failing scanner, not sail through because nobody read the
report carefully.

</details>

---

**4. Which pipeline order matches the reasoning in this module?**

- A. Human approval, then scan, then policy, then cost
- B. Cost, then scan, then policy, then human approval
- C. fmt/validate, then scan, then policy, then cost, then human approval
- D. Scan, then human approval, then policy, then cost

<details>
<summary>Answer</summary>

**C.** Cheapest and fastest checks run first, so a typo doesn't waste a scanner's runtime.
The most expensive step, a person's attention, runs last, only after everything upstream
has already said yes.

</details>

---

**5. A learner has not set up an Infracost account yet. What should this module's pipeline script do?**

- A. Print a plausible-looking dollar estimate anyway, so the pipeline output looks complete
- B. Crash with an unhandled error
- C. Skip the cost stage and say clearly that it was skipped, with instructions to enable it
- D. Silently pass the stage as if it succeeded

<details>
<summary>Answer</summary>

**C.** Never fabricate a number a tool didn't actually produce. An honest skip message with
a clear next step is correct, both in this course's own build discipline and in a real
pipeline a learner would run at work.

</details>

---

**6. In `main.tf`, a `#checkov:skip=CKV_AWS_144:...` comment is added above a resource, but Checkov still reports that finding as failed. What is the most likely explanation, based on what this module found?**

- A. The comment syntax always works, this must be a different bug
- B. Inline skip comments are not guaranteed to work for every check, and were confirmed not to work for this one, `--skip-check` on the CLI is the reliable path
- C. Checkov ignores all comments in Terraform files
- D. The resource needs to be deleted, not skipped

<details>
<summary>Answer</summary>

**B.** This module tested it directly: an isolated, minimal reproduction confirmed the
inline comment did not suppress the finding on checkov 3.3.16, while `--skip-check` on the
CLI did. The lesson generalizes: verify a suppression actually worked, don't assume it did
because the syntax looks right.

</details>

---

**7. Given the M01 thesis, "the agent proposes, the pipeline decides," where does this module's pipeline fit?**

- A. It replaces the thesis with a faster one
- B. It is the concrete, runnable version of the pipeline half of that sentence
- C. It only applies once the code has already been applied
- D. It is optional once a human has reviewed the code once

<details>
<summary>Answer</summary>

**B.** Every stage built in this module, scan, policy, cost, then human approval, is a real,
runnable piece of the pipeline side of the M01 authority boundary. The agent's job still
ends at generating a plan.

</details>
