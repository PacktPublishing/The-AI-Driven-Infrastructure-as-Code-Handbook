# AGENTS.md: Capstone repo conventions

Standing context for any agent working in this directory. See `spec.md` for this
task's requirements, constraints, and acceptance criteria.

## Provider pin

`aws` provider `~> 6.0`, matching `labs/shared/floci-spike/provider.tf`. Never leave
it unconstrained.

## Tags

Every resource that can carry tags gets `Environment`, `Owner`, `ManagedBy`. No
exceptions.

## Secrets

Never a secret in a `default`. Every variable that holds a credential is `sensitive = true`,
no default, set via `TF_VAR_<name>`.

## Blast radius

Stay under 5 managed resources in this module. If the task genuinely needs more,
split it, don't push past the gate's threshold.

## Pipeline order

`fmt`/`validate` → `trivy` → `checkov` → OPA/Conftest → blast-radius hook → human
approval → `apply`. Never skip a stage to save time; the pipeline decides, not the
agent.
