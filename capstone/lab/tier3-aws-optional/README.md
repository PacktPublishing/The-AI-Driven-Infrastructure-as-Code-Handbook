# Tier 3, Optional: the same pipeline against a real AWS account

**This part is optional. Nothing in the capstone requires it. Tier 1 (Floci) and Tier 2
(kind + Crossplane v2 + Argo CD) already exercise every stage of the pipeline for
real, at zero cost.** Run this only if you want the extra step of seeing the exact
same discipline hold up against a real cloud account, and only after reading the
three things below.

## Before you touch a real AWS account

**1. Set a billing/budget alert at $5.** Before you type a single `terraform apply`
against real AWS, go to Billing → Budgets in the AWS console and create a budget
alert at **$5**. This is not optional caution, it is the first numbered step. A
misconfigured resource left running can cost real money before you notice.

**2. Know the real cost of what you're about to run.** This module's Terraform
targets S3, a small EC2 instance, and DynamoDB, deliberately, because they stay
inside or close to the AWS free tier for a short-lived capstone run. **Do not extend
this to EKS for the capstone.** An EKS control plane costs **≈$73/month, with no free
tier**, regardless of how small the workload running on it is. If you want to see
this course's Kubernetes material against a real cluster, that is a separate,
deliberate decision outside the capstone, not a default extension of this exercise.

**3. Know your account's lifecycle.** A new AWS free-plan account **auto-closes
after 6 months or when its credits run out**, with a **90-day recovery window**
after closure. If you're running this months after creating a learner AWS account,
check your account status first.

## What this directory contains

- `main.tf`: the same storage-and-config resources as the Tier 1 Floci module (S3
  bucket, versioned, public-access-blocked; DynamoDB table, on-demand billing),
  targeting **real** AWS instead of Floci's emulation. Same tags, same
  sensitive-variable pattern, same pipeline (`fmt`/`validate` → Trivy → Checkov →
  the capstone's own OPA policy → the blast-radius hook → human approval → apply)
  applies unchanged, this file only removes the Floci `endpoints {}` block.
- `variables.tf`: the same `config_api_key` sensitive variable, no default.

## Numbered steps, if you choose to run this

1. Set the $5 budget alert (above), if you haven't already
2. `aws configure` with a real IAM user that has least-privilege access to S3 and
   DynamoDB only, not an account root key
3. `terraform init`
4. Run the exact same pipeline stages as Tier 1's `pipeline.sh`, pointed at this
   directory, ending in the same human-approval gate
5. `terraform apply`, once approved
6. Confirm the resources exist in the real AWS console
7. **`terraform destroy`**: the closing step, not a footnote. Confirm in the AWS
   console that both resources are actually gone before you close this out

## What was never done for you

This directory's Terraform was written and validated for correct syntax (`terraform
fmt`/`validate` against the real `aws` provider, with `skip_credentials_validation`
disabled so it genuinely requires real credentials) but **was never applied against
a real AWS account** while building this course. Every dollar this section might
cost is yours to decide to spend, not something the course spent on your behalf.
