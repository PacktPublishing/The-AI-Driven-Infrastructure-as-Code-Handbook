# M11 Projects: Safe Agentic Delivery to Production

Stretch projects. Hints, not solutions.

1. **Wire your own repo's pipeline into CI.** Take a gate you already run by hand, put it in
   a GitHub Actions workflow scoped to the right `paths:` filter. Open a real PR against
   your own change and watch it catch something real.

2. **Add a second gate stage.** Extend this module's workflow with a cost check or a policy
   check (callback to M09). What order should it run in relative to the existing stages, and
   why does order matter here?

3. **Break sync on purpose, the Flux way.** If your team prefers Flux over Argo CD, repeat
   this module's self-heal test using `flux` instead. What's different about how Flux
   reports sync and health compared to Argo CD's two-axis model?

4. **Design the step 6 gate you'd need.** If you wanted to remove even the human merge step
   for a specific, narrow class of change (say, a version bump with no other diff), what
   would have to be true first for that to be safe? Write it down. Don't build it.

5. **Write the rollback runbook this module didn't.** Pick a real "bad merge" scenario for
   your own stack. What's the actual sequence to get back to known-good, given that the
   controller only reconciles forward?
