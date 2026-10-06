---
name: capstone-conventions
description: House rules for the capstone's storage-and-config Terraform module. Use whenever asked to write, generate, or extend Terraform for this capstone task.
---

# Capstone module conventions

Same three rules as M04's `terraform-module-conventions` skill, restated for this task:

## Provider pin

Pin `aws` to `~> 6.0`, exactly as in `labs/shared/floci-spike/provider.tf`.

## Required tags

Every taggable resource carries `Environment`, `Owner`, `ManagedBy`.

## Secrets

Never a secret in a `default`. Credential-shaped variables are `sensitive = true`,
no default, set via `TF_VAR_<name>`.

## This task specifically

- The S3 bucket needs versioning enabled and a public-access block, per `spec.md`
  FR-001/FR-002
- The DynamoDB table is on-demand billing (`PAY_PER_REQUEST`), not provisioned
  capacity, per FR-003
- Stay at or under 5 total managed resources
