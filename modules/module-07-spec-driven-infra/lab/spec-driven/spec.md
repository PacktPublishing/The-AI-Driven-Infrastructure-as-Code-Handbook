# Feature Specification: Checkout Web Tier Autoscaling

## Requirements

### Functional Requirements

- FR-001: The Auto Scaling Group's health check grace period MUST account for the
  application's measured startup needs while limiting unhealthy-instance retention. This
  example sets 180 seconds as a configuration value, but EC2-only checks do not verify
  checkout application startup or readiness.
- FR-002: Scale-in MUST express a preference for terminating the oldest launch template
  version first, so a mid-rollout instance running the newest code is the last one
  considered rather than an arbitrary pick. This is a preference, not a guarantee: AWS
  balances Availability Zones before it applies termination policies, so an instance
  running new code can still be chosen if that is what rebalancing requires.
- FR-003: Capacity MUST be bounded to a known, justified peak, not an arbitrary round
  number. This tier's measured peak is 2x its steady-state baseline of 2 instances.
- FR-004: Scale-out MUST target average CPU utilization with headroom before saturation.
  Responsiveness MUST be set through instance warmup, which is what a target-tracking
  policy actually waits on. AWS documents that target-tracking and step-scaling policies
  can start a scale-out immediately without waiting for the cooldown to end. The group's
  cooldown MUST also be set explicitly rather than left at the provider's 5-minute
  default, which governs simple scaling policies and can still delay scale-in.
- FR-005: Instance metadata MUST require IMDSv2 tokens. IMDSv1 has no request signing and
  is a known SSRF pivot path into instance credentials.

### Constraints

- C-001: No account-specific value may be hardcoded into a resource block.
- C-002: The launch template and Auto Scaling Group must be wired together, not left as
  two independently-applied resources.

## Scope of this lab

This module is deliberately configuration-only. The launch template installs no
application, and the Auto Scaling Group uses EC2-only health checks, so nothing here
measures the checkout service actually surviving a slow start. What the lab proves is
narrower and still worth proving: that a written specification and the generated
Terraform agree, field by field, and that the agreement can be checked mechanically
rather than eyeballed. Real application startup behaviour, and whether 180 seconds is
the right number for your own boot sequence, is something you measure against your own
service, not something this emulator can tell you.

Two emulator limits worth stating plainly. Floci does not record
`default_instance_warmup`, so the lab asserts that value in the configuration. It also
drops a launch template's `metadata_options` entirely, so SC-005 is proved from the
plan's own JSON, which is what Terraform would actually send to the API, rather than
from applied state. SC-006 is read from Checkov's JSON result, not searched for in its
console text, because a text search cannot tell a check that passed apart from a scan
that never ran. Every remaining criterion is checked against what actually applied.

## Success Criteria

- SC-001: `health_check_grace_period` = 180
- SC-002: `termination_policies` = `["OldestLaunchTemplate", "OldestInstance", "Default"]`
- SC-003: `min_size` = 2, `max_size` = 4
- SC-004: an `aws_autoscaling_policy` of type `TargetTrackingScaling`, predefined metric
  `ASGAverageCPUUtilization`, `target_value` = 55, the ASG's `default_instance_warmup` = 90,
  and its `default_cooldown` = 90
- SC-005: the launch template's `metadata_options.http_tokens` = `"required"`
- SC-006: checkov passes `CKV_AWS_79` (IMDSv2) on the launch template -- see the note below
