# M07 Reference Card: Spec-Driven Infrastructure

One page. Pin it above your desk.

## The three parts of a spec

| Part | Answers | Example |
|---|---|---|
| Requirements | What must it do? | Survive a real cold boot, protect the newest release during scale-in |
| Constraints | What must it never do? | No unbounded capacity ceiling, ever |
| Success criteria | How will you check it, before you generate anything? | `health_check_grace_period` = `180` |

A one-line intent has none of these written down. A spec has all three.

## Vibe coding, named once

Generate → eyeball → tweak → eyeball again, no written target, no fixed criteria. Failed on
infrastructure specifically because infrastructure has no undo and failure that stays quiet
(M01's asymmetries). Never a recommended technique in this course.

## Spec vs gate vs policy: three different jobs

| Stage | Module | Does | Does not |
|---|---|---|---|
| Spec | M07 | Defines the ask, before generation | Block or scan anything itself |
| Gate | M06 | Blocks `apply` on something mechanical (blast radius) | Care how the module was written |
| Policy | M09 | Scans the generated plan against a ruleset | Get skipped just because a spec exists |

`apply` still needs a gate whether the module came from a careful spec or from guessing.
None of the three replaces the other two.

## When it's worth writing one

A one-line intent is enough for a throwaway, Tier 0, nobody-reviews-it exercise. Write the
spec once any of these is true: a real reviewer will read it, it holds real data or runs in
a real account, or you'll need to remember what "done" meant here in six months.

## Spec Kit, real commands

`/speckit-specify` → baseline spec · `/speckit-plan` → implementation plan ·
`/speckit-tasks` → actionable steps · `/speckit-implement` → generate against all of it.
Kiro specs: same idea, different tool.
