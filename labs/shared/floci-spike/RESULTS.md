# Spike result — PASSED

**Run:** 31 August 2026 · Floci **1.7.0** (`floci/floci:1.7.0`) · Terraform 1.16.0 · AWS provider ~> 6.0
**Verdict: Tier 1 is viable on Floci. Build the labs on it.**

## What was tested

The real 3-tier shape the course labs use — not a toy. 21 resources:
VPC · 2 public + 2 private subnets · IGW · route table + associations · 2 security groups ·
S3 bucket with versioning, SSE and public-access-block · IAM role, inline policy, instance profile ·
`aws_ami` data source · EC2 instance with `user_data` and an instance profile ·
DB subnet group · RDS MySQL 8.0.

## Results against the pass criteria

| # | Criterion | Result |
|---|---|---|
| 1 | `terraform apply` completes | **21/21 managed resources** (+2 data sources), `Apply complete!` |
| 2 | RDS is a real, connectable MySQL | **MySQL 8.0.46**, `devopsdb` present, credentials work |
| 3 | EC2 is a real Amazon Linux | **Amazon Linux 2023** container, `dnf` present at `/usr/bin/dnf` |
| 4 | `aws_ami` data source resolves | yes — returns a synthetic `ami-…` id |
| 5 | `terraform destroy` is clean | **21 destroyed**, state empty, **zero orphan containers** |
| 6 | Scanners run and disagree | **Trivy 7 HIGH/CRITICAL · Checkov 25 failures** on identical code |

Startup: **31 ms** (native GraalVM binary). 80 services reported healthy. Edition reports as
`community` / `floci-always-free`. MIT licensed, no account, no auth token.

## The one thing that will bite you

**The Docker socket must be mounted into the Floci container.**

```bash
docker run -d --name floci -p 4566:4566 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  floci/floci:1.7.0
```

Floci backs stateful services with real containers — `mysql:8.0` for RDS,
`public.ecr.aws/amazonlinux/amazonlinux:2023` for EC2, `alpine/socat` for networking. Without socket
access, `aws_db_instance` **hangs indefinitely** and the only clue is a misleading log line:

```
IllegalStateException: RDS runtime arn:aws:rds:... already has an active container
```

A learner hitting that will assume the lab is broken. **Put the socket mount in every lab's setup step
and call out the failure mode in the troubleshooting section.**

**On Windows, prefer WSL2 (Ubuntu).** From Git Bash, that `docker run` needs `MSYS_NO_PATHCONV=1` in
front of it, because MSYS rewrites the `/var/run/docker.sock:/var/run/docker.sock` argument into a
Windows path list before Docker sees it. `labs/shared/docker-compose.floci.yml` avoids the problem.
Git Bash has one more trap: pip's `checkov` launcher script cannot be executed by bash
(`checkov: cannot execute: required file not found`). `run.sh` here, and every lab script that scans,
sources `labs/shared/tool-shims.sh`, which falls back to `python -m checkov.main` and prints the
command it used. For a `checkov` command you type, run `python -m checkov.main` with the same
arguments. `labs/shared/tool-shims.test.sh` reproduces the failure on any machine and checks the
fallback.

## Constraints to design labs around

- **Pin `floci/floci:1.7.0`.** Nightlies ship daily; `latest` is a moving target mid-course.
- **Budget ~4 minutes for a full apply+destroy cycle.** RDS takes ~2–3 minutes to create — real container pull plus MySQL init. Pre-pull `mysql:8.0` and
  `amazonlinux:2023` on your host so the lab doesn't stall on a download.
- **Use the `endpoints {}` block, not `endpoint_url`.** Floci's README shows `endpoint_url`, which is
  not AWS-provider syntax. The working stub is `labs/shared/floci-spike/provider.tf`.
- **AMI ids are synthetic.** Fine for teaching the data-source pattern, which is what M03 and M07 need.
  Not usable for teaching AMI selection specifics.
- Emulation is API-shaped. It cannot teach IAM enforcement semantics, service quotas, real networking
  or cost. Those stay in Tier 3, optional.

## Bonus: this run is itself M09 teaching material

Identical code, two scanners, wildly different answers — **Trivy 7, Checkov 25**. That is the
"run both, Checkov is the strictly harder gate" lesson, reproducible on the learner's own machine in
under five minutes. Record this run as the M09 opening demo.

Checkov caught, among others: open SSH ingress, unrestricted egress, subnets assigning public IPs,
IMDSv1 enabled, unencrypted EBS, RDS without deletion protection / Multi-AZ / enhanced monitoring /
IAM auth, S3 without access logging or KMS encryption, no VPC flow logs.

## Re-run

```bash
cd labs/shared/floci-spike && ./run.sh
```
Exits non-zero on any failed criterion. Re-run whenever the pinned Floci version changes.
