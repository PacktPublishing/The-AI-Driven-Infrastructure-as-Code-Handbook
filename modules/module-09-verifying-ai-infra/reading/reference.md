# M09 Reference Card: Verifying AI-Generated Infrastructure

One side of A4. Pin it next to M01's ladder and M06's gate cheat sheet.

## The assembled pipeline

```
fmt/validate -> scan (trivy + checkov) -> policy (conftest) -> cost (infracost) -> human approval -> apply
```

Cheapest, fastest checks first. The most expensive step, a person's attention, last.

## What each tool catches that the others don't

| Tool | Catches | Doesn't catch |
|---|---|---|
| Trivy | Misconfigurations, granular public-access-block checks | Your org's own rules, cost |
| Checkov | A broader Terraform rule set for most AWS resources (replication, lifecycle, event notifications) | Your org's own rules, cost |
| Conftest / OPA | Whatever rule you write in Rego, your org's own conventions | Anything not explicitly written as policy |
| Infracost | Real dollar estimates against a real threshold | Security misconfigurations, org policy |

**Rule: run Trivy and Checkov together, always.** One alone is a coverage gap, not a safety
margin.

## Real numbers from this course's own repo

`labs/shared/floci-spike`, the real 21-resource module: **Trivy 7 HIGH/CRITICAL, Checkov 25
failed checks**. Reproducible in under a minute:

```
trivy config --quiet --severity HIGH,CRITICAL .
checkov -d . --compact --quiet --framework terraform --skip-download
```

## Gate vs report, in one line

A report is a number a human might read. A gate is a check wired to fail the pipeline. An
Infracost estimate printed to a Slack channel is a report. The same check with a real
threshold and a non-zero exit code is a gate.

## Checkov suppressions: what actually works

`#checkov:skip=CKV_XXX:reason` inline comments are not guaranteed to work for every check,
confirmed by direct test against checkov 3.3.16 in this course's own environment. The CLI
flag `--skip-check CKV_XXX,CKV_YYY` did work, reliably. Verify a suppression actually
suppressed the finding, don't assume the syntax alone did it.

## Cost check, no fabrication

`infracost auth login` once, free, no card, before the cost stage can run for real. A
pipeline script should detect a missing key and skip that stage with a clear message,
never print a guessed dollar figure.
