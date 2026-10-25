# M12 Projects: Loop Engineering for Infrastructure Agents

5 stretch projects. Hints, not solutions.

1. **Wrap one of your own checks.** Pick a rule your team enforces by memory. Write a
   `verify.sh` for it with the same three exits: 0 done, 1 not done with the findings on stderr,
   2 no verdict. Run `lab/loop/install.sh` against a copy of a real module and ask an agent for a
   narrow fix. Does the gate send it back? Hint: decide what "no verdict" means for your rule
   before you write the "done" branch.

2. **Make the judge argue.** Run the same task under `/goal` and under the Stop gate, three times
   each, and read the traces with `lab/loop/trace.py`. Where does the evaluator send the agent
   back, and why? Where does the gate? Hint: read every word of your `/goal` condition as part of
   the gate, and keep any turn budget out of what must be true.

3. **Add a checker.** Add a second agent that reviews the diff for naming and structure only, and
   keep the scanner as the gate. Which of its comments would a script have caught? Hint: Claude
   Code's agent teams carry the gate idea to each teammate through a `TaskCompleted` hook that
   exits with code two. Teams are experimental and switched off by default.

4. **Price your loop.** Run `trace.py` on a week of your own loop's runs. What does one "done"
   cost, and what does one "budget exhausted" cost? Hint: the cost comes from the runtime's own
   event stream, so capture every run with `--output-format stream-json`.

5. **Make the nightly version real, in a sandbox repository.** Start from
   `lab/solution/trigger-workflow.example.yml` in a throwaway repository of your own, lint it with
   `actionlint`, and let it run on its schedule for a week. Hint: the job should take its colour
   from `.loop/state.md`, never from what the agent said, and it should hand the diff to a human
   rather than push it. Then trust-check the Codex side: what happens on a fresh checkout before
   anyone runs `/hooks`?
