# End-to-End AWS Cost Optimization Guide

A practical, implementable walkthrough for cutting AWS spend in a real account.
Every section maps to a concrete artifact in this repository so you can deploy,
measure, and iterate — not just read.

The flow follows the four phases of a FinOps loop: **see → govern → optimize → keep clean.**

| Phase | Goal | Where it lives |
|---|---|---|
| 0. See | Find the waste | `screenshots/`, `docs/audit-report.md`, Cost Explorer |
| 1. Govern | Stop new waste at the door | `terraform/02-governance/` (Budgets + SCP) |
| 2. Optimize | Re-architect what's left for lower unit cost | `terraform/03-optimization/` (Spot + Mixed-Instances ASG) |
| 3. Keep clean | Continuously sweep | `custodian-policies/`, `scripts/` |

---

## Phase 0 — See the waste before you touch anything

You cannot optimize what you cannot see. Spend an hour here before writing a
single line of Terraform.

1. **Cost Explorer, last 30 days, grouped by Service.** This usually surfaces
   the top three offenders (EC2-Other = EBS/NAT, EC2-Instance, RDS).
2. **Cost Explorer, grouped by Tag.** If most spend lands in *No tag applied*,
   your first optimization is governance, not architecture (Phase 1).
3. **AWS Compute Optimizer.** Free. Returns rightsizing recommendations with a
   projected dollar saving per resource. Treat its *Over-provisioned* list as
   your initial backlog.
4. **Trusted Advisor → Cost Optimization.** Free for the basic checks; the
   business-support checks (idle load balancers, underutilized EBS) are worth
   the support tier on any account spending >$2k/month.

Document the baseline in `docs/audit-report.md` so later "we saved $X" claims
are defensible.

---

## Phase 1 — Govern: stop the bleeding

Implemented in `terraform/02-governance/`. Two controls, both cheap, both
deploy in minutes:

### 1.1 Budgets with tiered alerts

`modules/governance/budget` provisions an `aws_budgets_budget` with three
notifications:

| Tier | Trigger | Type | Purpose |
|---|---|---|---|
| Warning | 33% of limit | ACTUAL | Engineering FYI |
| Elevated | 66% of limit | ACTUAL | Team lead attention |
| Critical | 100% forecasted | FORECASTED | Finance owner intervenes |

> Forecasted alerts matter more than actual alerts: by the time *actual* fires,
> the money is already spent.

Apply it:

```bash
cd terraform/02-governance
terraform init
terraform apply -var="alert_email=you@example.com"
```

### 1.2 Tagging enforced by SCP

`modules/governance/scp` denies `ec2:RunInstances` when the `CostCenter` tag
is absent. The SCP is attached at the account level so it applies to every
principal — including humans clicking the console.

A few practical notes:

- **An SCP requires AWS Organizations.** In a standalone account, replace the
  SCP with an IAM permissions boundary or an SCP-equivalent IAM policy
  attached to every role.
- **Start with one tag (`CostCenter`), not five.** Each required tag is a new
  way for a legitimate deploy to fail at 3am.
- **Roll out in `Audit` mode first** if your org supports it. Otherwise, ship
  the SCP behind a feature flag (apply to a single OU/account) and watch
  CloudTrail for `AccessDenied` for 48h before expanding.

---

## Phase 2 — Optimize: re-architect for unit-cost wins

Implemented in `terraform/03-optimization/`. The headline pattern is **Mixed
Instances Policy ASG behind an ALB**, which is the canonical AWS way to run
stateless workloads for ~50–70% less than On-Demand-only.

### 2.1 What the stack actually creates

```
                  Internet
                     │
                     ▼
              ┌──────────────┐
              │  ALB (HTTP)  │  aws_lb.app
              └──────┬───────┘
                     ▼
              ┌──────────────┐  target_group_arns,
              │  ASG (2..6)  │  health_check_type = "ELB"
              └──────┬───────┘
                     ▼
         ┌─────────────────────────┐
         │ Mixed Instances Policy  │
         │  • 1 On-Demand baseline │  (var.on_demand_base_capacity)
         │  • 0%  OD above base    │  → everything else is Spot
         │  • price-capacity-      │
         │    optimized strategy   │
         │  • t3 / t3a, micro/small│  (var.instance_overrides)
         │  • capacity_rebalance=t │  proactive Spot replacement
         └─────────────────────────┘
                     ▲
                     │  ASGAverageCPUUtilization @ 50%
              Target-tracking scaling policy
```

Apply it:

```bash
cd terraform/03-optimization
terraform init
terraform apply
# outputs: alb_dns_name, asg_name, launch_template_id, scaling_policy_arn
```

Verify the workload responds:

```bash
ALB=$(terraform output -raw alb_dns_name)
curl -s "http://$ALB" | grep lifecycle
# → <p>lifecycle: spot</p>  (most of the time — depends on which instance answers)
```

### 2.2 Why these specific knobs

| Setting | Value | Why |
|---|---|---|
| `on_demand_base_capacity` | `1` | Guarantees at least one instance survives a Spot interruption storm. |
| `on_demand_percentage_above_base_capacity` | `0` | Anything you scale up is 100% Spot. |
| `spot_allocation_strategy` | `price-capacity-optimized` | AWS picks pools that are *both* cheap *and* deep — interruption rates drop sharply vs `lowest-price`. |
| `instance_overrides` | `t3/t3a × micro/small` | 4 pools across two CPU families. More pools = lower interruption rate. Mixing `t3a` (AMD) with `t3` (Intel) typically adds another 10% discount. |
| `capacity_rebalance` | `true` | When EC2 issues a *rebalance recommendation* (warning that an interruption is likely), ASG launches a replacement **before** the kill notice. |
| `health_check_type` | `"ELB"` | ASG replaces instances that fail HTTP health checks, not just ones that fail EC2 status checks. |
| `instance_refresh.min_healthy_percentage` | `50` | Launch-template edits roll out without downtime. |
| `lifecycle.ignore_changes = [desired_capacity]` | — | The scaling policy owns `desired_capacity`; Terraform must not fight it. |

### 2.3 Sizing decisions that don't show up in code

The IaC is the easy part. The judgment calls:

- **Is the workload actually stateless?** If it writes to local disk, holds
  session state in memory, or depends on a slow warm-up, Spot will hurt. Move
  state to RDS/ElastiCache/S3 first, then come back to this stack.
- **Can it tolerate a 2-minute notice?** Spot interruptions arrive with a
  120-second warning via instance metadata. Your shutdown path (drain from
  ALB, finish in-flight requests) must fit in that budget. The default
  deregistration delay on a target group is 300s — drop it to 60s for Spot
  fleets.
- **Is it horizontally scalable?** Vertical-only workloads (single big Redis,
  monolithic Java app with 30s JVM warm-up) are not Spot candidates regardless
  of architecture.

### 2.4 Rightsizing (the other 30% of EC2 spend)

Mixed-Instances Spot wins on *unit* cost. Rightsizing wins on *quantity*.
Run both.

- Pull Compute Optimizer findings monthly: `aws compute-optimizer get-ec2-instance-recommendations`.
- For anything tagged `Environment=audit-lab` or `Environment=dev`, default to
  downsizing one tier on any recommendation with ≥90% confidence.
- Modernize aggressively: `t2 → t3 → t3a → t4g` is a free ~40% saving on most
  workloads that don't pin to x86.

### 2.5 Storage (EBS, snapshots, S3)

Not in this stack yet but the same playbook:

- Convert all `gp2` to `gp3` — 20% cheaper at identical IOPS for volumes ≤3000 IOPS.
- Enforce a Data Lifecycle Manager policy that deletes snapshots >30 days old
  unless tagged `Retain=true`.
- For S3, apply lifecycle rules: Standard → Standard-IA at 30d, Glacier
  Instant Retrieval at 90d, Glacier Deep Archive at 365d. Default object
  ownership *bucket owner enforced* so ACL drift doesn't break the rules.

---

## Phase 3 — Keep clean: continuous sweep

Optimization decays. Engineers spin up test resources, forget them, leave the
company. Cloud Custodian is the cron that catches the regressions.

### 3.1 Audit first, mutate later

Every policy ships with a dry-run mode. Use it for the first week:

```bash
uv tool run --from c7n custodian run \
  --dryrun --region eu-west-1 --profile nsp-sandbox \
  -s ./out custodian-policies/policies/
```

Read the per-resource JSON in `./out/<policy-name>/resources.json`. Anything
flagged that is *not* actually waste is a tagging gap to fix before you let
Custodian start deleting.

### 3.2 Mark-and-sweep cadence

The repo's policies follow the standard FinOps two-step:

1. **Day 0 — mark.** Tag the offender with `cost-detective/marked-for-op=<date>`.
2. **Day N — sweep.** Re-run; delete anything still bearing the mark.

This gives owners a window to add a `Retain=true` tag if the resource is
actually load-bearing. 14 days is a humane default; 2 days fits the lab.

### 3.3 What's covered

| File | Resource | Action |
|---|---|---|
| `policies/ebs/*.yml` | Unattached `gp2`/`gp3` volumes | mark → delete |
| `policies/ec2/*.yml` | Idle EC2, missing-tag EC2 | mark → stop → delete |
| `policies/vpc/*.yml` | Unassociated EIPs, idle ALBs | mark → release/delete |

### 3.4 Running it on a schedule

Custodian is meant to live in a Lambda fired by CloudWatch Events:

```bash
uv tool run --from c7n custodian run \
  --region eu-west-1 --profile nsp-sandbox \
  -s ./out custodian-policies/policies/
```

For production, replace the local CLI invocation with `c7n-org` plus a
GitHub Actions workflow on a daily cron, or with `c7n-mailer` so resource
owners get the notification before the sweep, not after.

---

## Validating the end-to-end story

After deploying all three stacks:

1. **Cost Explorer, 7 days post-apply, filter `Project = cost-detective`.**
   The 03-optimization stack should appear with EC2 spend dominated by
   `Usage Type = SpotUsage:*` instead of `BoxUsage:*`.
2. **Spot Instance Advisor for your chosen instance pools** (in the EC2
   console). Confirm <10% interruption frequency. If higher, add more
   instance types to `var.instance_overrides`.
3. **Budgets dashboard.** Confirm the three alerts are armed and the
   forecast is below the limit.
4. **Custodian dry-run output.** Should be empty for resources you've already
   cleaned — anything still listed is either new waste or a tag gap.

---

## Teardown

Always destroy in **reverse order** of apply (03 → 02 → 01) so that resources
governed by the SCP can still be deleted:

```bash
cd terraform/03-optimization && terraform destroy
cd ../02-governance       && terraform destroy
cd ../01-wasteful-resources && terraform destroy
```

If `03` destroy hangs on the ASG, it's almost always Spot capacity
rebalancing during scale-in. Set `desired_capacity = 0` and apply, wait for
instances to drain, then destroy.
