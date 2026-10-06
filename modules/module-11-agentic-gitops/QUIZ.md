# M11 Quiz: Safe Agentic Delivery to Production

9 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. What changed about the M09 pipeline's stages when they moved into GitHub Actions?**

- A. The stages themselves changed to be CI-specific
- B. Nothing about the stages changed, only who runs them, automatically on every pull request instead of by hand
- C. Checkov can no longer run inside GitHub Actions
- D. The pipeline gets faster because CI skips real scanning

<details>
<summary>Answer</summary>

**B.** Same `fmt`, `validate`, `trivy`, `checkov`, same order. A pull request runs them now,
instead of a person typing each command.

</details>

---

**2. Which of the following is the most precise one-sentence definition of GitOps?**

- A. Running Terraform inside a CI pipeline
- B. The repo is the source of truth, and a controller keeps the cluster matching it
- C. Storing YAML files in git instead of a database
- D. Any workflow that uses `kubectl` and `git` together

<details>
<summary>Answer</summary>

**B.** Plain CI/CD (A) just runs commands on a trigger. GitOps specifically means a
controller continuously reconciles a live system against what's in the repo, not a one-shot
run.

</details>

---

**3. A resource shows `SYNCED: True` and `HEALTHY: False`. What does that combination actually mean?**

- A. The cluster doesn't match the repo yet
- B. The cluster matches the repo exactly, but what's running isn't actually working
- C. This combination is impossible
- D. The controller crashed

<details>
<summary>Answer</summary>

**B.** Synced and healthy are two separate questions. A resource can match the repo
perfectly and still be broken, a crash-looping pod is the classic example.

</details>

---

**4. Trace the full loop from this module. What is the one manual step in it?**

- A. Writing the Terraform or Kubernetes manifest
- B. Running the CI pipeline
- C. Reading and merging the pull request
- D. Running the sync after merge

<details>
<summary>Answer</summary>

**C.** The pipeline gates automatically. The controller reconciles automatically, after and
independent of any single merge. The only step a human still does by hand is reviewing the
pull request and deciding to merge it.

</details>

---

**5. Why is this module's loop called step 5, supervised autonomy, and not step 4, gated apply?**

- A. Because no gates run at all
- B. Because a human approves one specific action at a time, same as step 4
- C. Because the agent's work spans multiple automatic actions (the gate, the sync, the self-heal), and a human reviews the outcome rather than approving each one
- D. Because no human is involved anywhere in the loop

<details>
<summary>Answer</summary>

**C.** Step 4 means one approved action at a time. Here, multiple things happen on their
own, the pipeline runs, the controller syncs, self-heal corrects drift, and the human only
reviews the pull request's outcome before merge, not each of those events separately.

</details>

---

**6. Why doesn't this module claim to have closed the rollback and incident-response gap?**

- A. Because those problems don't apply to GitOps
- B. Because Argo CD and Flux solve both automatically, no further work needed
- C. Because they're genuinely real, separate practices with their own tooling and care, and pretending otherwise would be dishonest
- D. Because this course covers them in module 9 instead

<details>
<summary>Answer</summary>

**C.** Reconciling forward toward the repo's current state isn't the same as safely
reverting to a known-good one, and a controller that's itself failing needs a real incident
process. Naming both honestly beats implying they're solved.

</details>

---

**7. What would move this module's loop from step 5 to step 6, unattended?**

- A. Installing Flux instead of Argo CD
- B. Removing the human review and merge step itself
- C. Adding more scanners to the CI pipeline
- D. Making the reconcile loop run faster

<details>
<summary>Answer</summary>

**B.** Every piece needed to remove the human from the merge already exists technically.
Step 6 would mean actually doing that: no human decision anywhere in the loop. This course
doesn't teach that as a default.

</details>

---

**8. In the lab, an agent opened a real pull request with a hardcoded key in it, and its own
output noted the mistake in passing without stopping itself. What actually caught it?**

- A. The agent caught its own mistake and refused to commit
- B. Nothing caught it, the flaw shipped
- C. The CI pipeline's checkov stage, automatically, on the pull request
- D. A human reviewed the diff before it was pushed and caught it

<details>
<summary>Answer</summary>

**C.** The agent noticed and said so, but noticing isn't the same as stopping. It committed
and pushed anyway. Nobody reviewed the diff before it went out either. What actually blocked
the change was the automated pipeline running on the pull request, catching `CKV_SECRET_2`
and failing the check. That's the whole point of putting a gate after the agent instead of
trusting the agent's own judgment.

</details>

---

**9. This chapter names four separate jobs in a safe agentic delivery chain: propose,
automated review, human merge, apply. Which one does GitOps actually do?**

- A. GitOps does all four
- B. GitOps is the "apply" step only, the other three already had to happen first
- C. GitOps replaces the need for automated review
- D. GitOps is the "propose" step, since Argo CD watches the repo for changes

<details>
<summary>Answer</summary>

**B.** GitOps reconciles a cluster to match a merged repo, that's step 4. It says nothing
about whether the change was safe to merge in the first place, that's steps 1 through 3: an
agent proposing a change, a pipeline reviewing it automatically, and a human reading the
outcome before merging. GitOps is real and useful, but it's the last link, not the whole
chain.

</details>
