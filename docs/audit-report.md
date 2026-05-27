# Cost Detective Audit Report

## Phase 2: Governance Implementation

The governance framework establishes preventative controls to manage costs actively rather than relying purely on reactive measures.

### 1. Cost Control Budget (3-Tier Alert System)
An overarching AWS budget has been implemented with a maximum limit of $15. To avoid alert fatigue and provide an escalating urgency flow, a 3-tier notification system alerts administrators via email when thresholds are breached.
- **Tier 1 (Warning):** Triggers when *Actual* spend exceeds 33.33% (~$5).
- **Tier 2 (Elevated):** Triggers when *Actual* spend exceeds 66.66% (~$10).
- **Tier 3 (Critical):** Triggers when *Forecasted* spend exceeds 100% ($15).

### 2. Preventive Tagging Policy
To ensure all resources are appropriately tracked for chargebacks, we implemented an AWS Organizations Service Control Policy (SCP).
- **Control:** Explicitly **Denies** the `ec2:RunInstances` action unless the `aws:RequestTag/CostCenter` tag is supplied during the creation request.
- **Rationale:** A preventative SCP is more effective than an AWS Config detective rule, as it outright halts the creation of non-compliant infrastructure at the API level, rather than flagging it after the cost has begun to incur.
