# M08 Projects: Harness Engineering

3 to 5 stretch projects. Hints, not solutions.

1. **Write a harness for your own team's most-skipped discipline.** What gets dropped under
   deadline pressure at your job? Write a skill stating the rule, then a hook that actually
   enforces it. Test that it can genuinely block a real bad case.

2. **Try to fool your own hook.** Rephrase a completion claim to slip past your regex. Where did
   it get through? Tighten the pattern, retest.

3. **Root-cause discipline, mechanically.** Write a hook or skill that blocks a "fixed" claim
   unless a failing-test-first step is evidenced earlier in the same session. What would that
   check actually need to look for?

4. **Audit a real incident for a missing harness.** Pick a past bug that shipped despite someone
   claiming "tests pass." What evidence, if a hook had required it, would have caught it?

5. **Combine M05 and M08.** Write a hook that requires a real MCP tool call (not just any command
   output) as the evidence for a specific kind of claim, e.g. "the provider version is current."
