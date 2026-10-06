# M03 reference card: Context Engineering for Infrastructure

One side of A4. Pin it above your desk.

## The context symptom test (from M01)

| Symptom | Layer |
|---|---|
| "Can't get one task right at all" | Context (this module) |
| "Works, but ignores our standards" | Harness (M06) |
| "Works, but I babysit every run" | Loop (M12) |

## The 3R model: three disciplines, not one file

| Discipline | Question | Real example from this module |
|---|---|---|
| Reduce | What enters the window? | `checkov --compact`, ~85% smaller, same findings |
| Retain | What survives a reset? | `AGENTS.md`, written once, read every session |
| Route | Where does the plan live? | `STATE.md`, a fresh session reads it and continues |

Miss one, the other two don't save you. A well-filtered, well-retained context
is still useless if a three-hour task's plan only ever lived in a conversation
that just got cleared.

## Context engineering vs a prompt

| | Context | Prompt |
|---|---|---|
| Written | Once | Every time |
| True | Every run | This run only |
| Lives in | `AGENTS.md` / `CLAUDE.md` | The chat window |
| Example | "Secrets are always `sensitive`" | "Build me a VPC with two subnets" |

## AGENTS.md checklist

- [ ] Provider + version pins, exact, not a range
- [ ] Naming convention, with a real example
- [ ] Module boundaries, one module per concern
- [ ] A never-do list, written as flat rules
- [ ] Where secrets come from (`TF_VAR_`, never a `default`)

## The information gap

**11 of 14** residual policy failures resolved once policy text was made visible
to the agent. Not a rounded 79%. The fix was not a smarter model, it was making an
existing rule readable at the moment the agent needed it.

## The rule

An agent finds files the way a human does: by name, by path, by what looks
relevant. Organize your repo for a human reader first, and you have mostly
organized it for an agent too.

## Route: the state-file pattern

```
## Where this stands
<what's done, what's not, in one or two lines>

## Decision already made, do not re-litigate
<the call that was already made, and why, so a fresh session doesn't reopen it>

## Next action
<the exact next step, specific enough that "read this and do it" is enough>
```

Write it to disk before a context clear, a session end, or a handoff to
someone else, agent or human. A conversation you clear is gone. A file on
disk is still there.
