# M07 Exploratory Projects: Spec-Driven Infrastructure

3-5 seeds. Hints, not solutions.

1. **Write a spec for a real ticket.** Take something underspecified from your own
   backlog, not a toy example. Write requirements, constraints, and acceptance criteria
   before you generate anything against it.

2. **Reconstruct a vibe-coded mess.** Find infrastructure code in your own history that
   was iterated on by feel, no written target. Write the spec it should have had. What
   would that spec have caught before the code ever shipped?

3. **Where's the line?** Write your own team's one-paragraph rule for when a one-line
   intent is enough and when a spec is required. Defend it against a colleague who
   disagrees.

4. **Run both scanners against your spec-driven module.** Trivy and Checkov, from M09.
   Does either one catch something your spec's acceptance criteria didn't ask for? That
   gap is real, not hypothetical, see this module's own lab.

5. **Try Spec Kit or Kiro specs on a non-Terraform task.** The spec/requirements/
   constraints/criteria pattern isn't infrastructure-specific. Try it on a small script or a
   CI config change and see what changes about how you'd review the result.
