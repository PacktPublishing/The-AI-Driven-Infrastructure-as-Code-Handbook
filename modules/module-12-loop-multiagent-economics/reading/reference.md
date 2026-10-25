# M12 Reference Card: Loop Engineering for Infrastructure Agents

## The six parts of a loop

| Part | Question it answers | In this module's lab |
|---|---|---|
| Trigger | What starts or restarts the agent? | The previous turn ending, a `/loop` interval, a nightly schedule |
| Work | Who does the task? | The agent, inside the harness from Modules 3 to 8 |
| Verifier | Is the job done, yes or no? | `loop/verify.sh` |
| Stop rules | Stop, go again, or stop and tell a human? | `loop/hooks/stop-gate.sh` |
| Budget | How many times round, how long, how much money? | Five blocks, then "budget exhausted" |
| State | What does the loop remember between runs? | `.loop/state.md`, in the repository |

Miss the trigger: one good run, once. Miss the verifier: it runs until someone kills it. Miss the
budget: a loop that cannot succeed spends until the month ends.

## Four primitives, two runtimes

| Primitive | Next turn starts when | Claude Code | Codex |
|---|---|---|---|
| Goal | the previous turn ends and a judge says "not yet" | `/goal <condition>` | `/goal` |
| Stop hook | the previous turn ends and your script says "not yet" | `Stop` in `.claude/settings.json` | `Stop` in `.codex/hooks.json` |
| Interval loop | a fixed or self-chosen interval passes, in an open session | `/loop 15m <prompt>` | an automation in the app |
| Schedule | a clock fires, with no session open | routines, Desktop tasks, GitHub Actions | automations, GitHub Actions |

`/loop` dies with the terminal, and recurring tasks expire after seven days. Use a schedule for a
control that must run on the nights nobody is at a desk.

## Who decides "done"

| Judge | Reads | Judge is |
|---|---|---|
| Completion phrase (`ralph-loop`) | What the agent says: it prints `DONE` | the worker |
| Model evaluator (`/goal`) | The transcript only. It "doesn't run commands or read files independently" | a second model |
| Deterministic gate (Stop hook + `verify.sh`) | The repository: it runs the scanner on the files | the pipeline |

## The verifier contract: `loop/verify.sh`

| Exit | Meaning | Gate does |
|---|---|---|
| 0 DONE | `terraform validate` passes and Checkov (`terraform,secrets`) reports no failed checks | lets the agent stop, writes `- done` |
| 1 NOT DONE | Checkov failures, printed on stderr. A `checkov:skip` comment also counts: a suppression is not a fix | exit 2, findings become the next instruction, writes `- blocked` |
| 2 NO VERDICT | a tool is missing, or `terraform init` or `validate` failed | lets the session end, writes `- no verdict` for a human |

## The Stop hook contract

- **Input on stdin:** a JSON object with the session, the transcript path, the last assistant
  message and `stop_hook_active` (true when this turn is already a Stop-hook continuation).
- **Exit 0:** the agent stops. **Exit 2** with a reason on stderr: the agent does not stop, and
  the reason is its next instruction. Codex uses the same exit code and also accepts JSON with
  `decision: "block"` and a `reason`.
- **Our gate ignores the transcript** and asks the repository. That is the difference from `/goal`.
- **Caps:** our gate releases after five blocks as "budget exhausted". Claude Code overrides a
  Stop hook after 8 continuations in a row with no tool use between them.
- **Codex trust:** a project hook runs only after someone trusts it with `/hooks`, recorded against
  a hash of the hook. Change it and it must be trusted again. In `codex exec` an untrusted hook is
  skipped without a word, so check `.loop/state.md` after every run.
- **Guard:** `loop/hooks/guard-oracle.sh`, a PreToolUse hook, refuses edits under `loop/`,
  `.claude/`, `.codex/` and `.loop/`. The agent may not edit the thing that judges it.

## Topology rule

| Topology | Use it for |
|---|---|
| One agent and a gate | The default. Anything a scanner, test, plan or policy can check |
| Maker and checker | Questions that need judgment: structure, naming, "is this the change the ticket asked for". The gate still decides facts |
| Fan-out on worktrees | Only independent pieces, when wall-clock time, not correctness, is the bottleneck. Agent teams are experimental and use significantly more tokens |

## Token-saving tools, measured (JetBrains, paired A/B, July 2026)

Same tasks with and without each tool, Claude Code on the SkillsBench task set.

| Tool | Advertised | Measured |
|---|---|---|
| caveman skill | 65% saving | 8.5% saving |
| rtk command rewriter | 60 to 90% saving | about 7.6% **more** expensive at low reasoning effort, 80 clean pairs; no measurable difference at high effort |

Task quality did not change in either arm. Read your own loop's cost with `lab/loop/trace.py`.

## Step 6, unattended

No human approves each run. A person appears only on an exception: budget exhausted or no
verdict. Safe only on top of a gate (Module 6), a workflow harness (Module 8) and a real pipeline
(Module 9). Without all three, "unattended" means "unsupervised".
