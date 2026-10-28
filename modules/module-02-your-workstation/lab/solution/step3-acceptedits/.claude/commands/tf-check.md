---
description: Run this course's Terraform checks (fmt, validate, plan) against the current directory
---

Run, in order, in the current directory, and report the real output of each:

1. `terraform fmt -check -diff`
2. `terraform init -backend=false -input=false -no-color`
3. `terraform validate -no-color`
4. `terraform plan -no-color`

Stop and report immediately if any step fails. Do not continue past a failure, and do not
summarize a step you didn't actually run.
