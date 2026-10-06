# M02 Reference Card: Your Agentic IaC Workstation

## Install and verify

```
claude --version
codex --version
```

## Pinned tool verify checklist

```
terraform version    # 1.16.0, pinned
checkov --version     # 3.3.16, pinned
docker info           # reachable at /var/run/docker.sock
```

If `docker info` hangs, stop and fix Docker before anything else. This blocks every later
Tier 1 lab too.

## Tools and permission mode, the two real dials

```
--allowedTools "Bash,Read,Write,Edit,Glob,Grep,WebFetch,WebSearch"
--allowedTools "Bash(terraform *)"          # scoped: only terraform commands
--permission-mode manual|acceptEdits|plan|dontAsk|bypassPermissions|auto
```

| Mode | What it does |
|---|---|
| `manual` / `auto` | Confirm each tool call that needs it (interactive default) |
| `acceptEdits` | File edits auto-applied, other tools still confirm |
| `plan` | Writes a plan, touches nothing until you say go |
| `dontAsk` | Skips most confirmation, still respects `--allowedTools` |
| `bypassPermissions` | No confirmation, no `--allowedTools` boundary. Sandboxes with no internet access only |

## Step 1 vs step 2 vs step 3 preview, in one table

| | Step 1: suggest | Step 2: draft | Step 3: plan (previewed here, taught from M04) |
|---|---|---|---|
| Who moves the file into place | You, copy/paste or redirect | The agent, directly | Nobody yet, it's a plan document |
| `--allowedTools` used | `""` | `"Write,Edit"` | irrelevant, `--permission-mode plan` |
| Agent touches disk | No | Yes | No, writes a plan file only |
| On the autonomy ladder | Step 1 | Step 2 | Step 3 |

## The real finding

Same intent, same model, two sessions: the outputs can genuinely differ. Nothing carries
memory between fresh sessions unless something is built to give it that memory on purpose
(module 3's subject). Read every line, every run, not just the first one.

## The second real finding: validate is not enough

Both real sessions above also made the same mistake: a `docker_container` volume `host_path`
that referenced `path.module` without `abspath()`. `terraform validate` passed both times.
`terraform plan` did not:

```
Error: './site' must be an absolute path
```

Fix: wrap the reference in `abspath()` at the point Docker needs it. Run `plan`, not just
`validate`, as your own minimum check from here on, in this course and outside it.

## Subagents: when to delegate

One-line rule: delegate a **bounded, well-defined** check to a subagent when you want the
answer without spending your main session's context on it, or without giving that check more
tool reach than it needs. A subagent's permissions are its own, narrower by default than the
parent session's, not inherited wholesale. A blocked subagent call that reports honestly
instead of guessing is working as intended.

## Slash commands: where they live

```
.claude/commands/<name>.md      # project-scoped, checked into the repo
~/.claude/commands/<name>.md    # personal, this machine only
```

Frontmatter `description:` plus a plain-language body describing what to run and in what order.
Invoke with `/<name>`. A slash command is a fact the repo carries, not a sequence one person
has to remember.

## Where standing config lives (empty until module 3)

| Tool | File |
|---|---|
| Claude Code | `CLAUDE.md`, at the repo root |
| Codex | `AGENTS.md`, at the repo root |
