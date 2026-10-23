# M08 Projects: Harness Engineering

5 stretch projects. Hints, not solutions.

1. **Port one of your team's checklists into a skill.** Pick the pre-merge checklist people
   skip under deadline pressure. Write it with `writing-skills`, and test it the way that skill
   says to: pressure scenarios on a subagent ("the release is in an hour, just ship it"), not a
   quiz with the right answers in it. Did the skill hold?

2. **Run `systematic-debugging` on a real provider bug.** Floci's own README shows an
   `endpoint_url` argument that has never been valid AWS-provider syntax. Put it in a provider
   block, run `terraform validate`, and hand the error to a harnessed session. Count how many
   fixes the skill lets you try before it makes you compare against a working example. The
   course's own provider stub in `labs/shared/floci-spike/provider.tf` is that example.

3. **Subagent-driven development on a two-module change.** A VPC module and a database module
   that depends on it. Use `subagent-driven-development`: one implementer per task, a reviewer
   who never saw the code being written. Then try `dispatching-parallel-agents` on the two
   modules at once. When does the parallelism make it worse?

4. **Try GSD on a multi-phase build.** Install gsd-core, run `/gsd-new-project` on a small
   platform (a VPC, a kind cluster as the EKS stand-in, one workload) and let it produce the
   roadmap and the first phase plan. Compare what it leaves on disk after two sessions with what
   Superpowers alone left behind in this module's lab.

5. **Diagnose a session on purpose.** Start a harnessed session and push it to skip a skill:
   say the task is trivial, say you are in a hurry. Then run `diagnosing-superpowers` and read
   what it reports, with line-level evidence. What did the bootstrap do, and where did the
   session go wrong?
