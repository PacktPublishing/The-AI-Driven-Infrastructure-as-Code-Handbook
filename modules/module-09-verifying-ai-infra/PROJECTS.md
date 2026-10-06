# M09 Exploratory Projects

5 stretch projects. Hints, not solutions.

1. **Run both scanners against a real repo you own.** Where do the counts diverge? Pick one
   finding each tool caught that the other missed and explain why, in your own words, the
   way this module's lab did for `CKV_AWS_144`.

2. **Write your team's own OPA policy.** Something you already enforce by memory in code
   review. A naming convention, a required tag, an approved module registry. Get it failing
   on a real violation, then fixing.

3. **Pick a real cost threshold and test it against a past surprise.** If your team has ever
   been surprised by a cloud bill, what threshold, wired as a real gate, would have caught
   the plan before it shipped?

4. **Audit a suppression in your own codebase.** Find a `# noqa`, `#checkov:skip`, or similar
   comment somewhere real. Confirm, the way this module did, that it's actually doing what
   everyone assumes it's doing.

5. **Time your own pipeline.** Run `fmt`, `validate`, both scanners, and a policy check
   against a module you use often. Where does the cheap-to-expensive ordering argument from
   this module actually save you real wall-clock time?
