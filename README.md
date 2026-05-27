# Cost Detective Audit

## Overview
Cost Detective Audit is a comprehensive DevOps and FinOps simulation project designed to model, identify, and remediate cloud cost waste within Amazon Web Services (AWS). 

The repository utilizes Terraform to intentionally provision underutilized and orphaned AWS resources. Subsequently, it employs Cloud Custodian, a robust open-source cloud security and governance engine, alongside custom automation scripts, to automatically audit, report, and clean up these wasteful configurations. This project serves as a practical blueprint for implementing FinOps practices and automated governance in enterprise cloud environments.

## Architecture and Simulated Waste
The Terraform configurations in this repository deploy a foundational VPC architecture and several "wasteful" resources for simulation purposes:
* **Idle EC2 Instances:** Instances running with negligible CPU utilization.
* **Unattached EBS Volumes:** Provisioned storage volumes that are available but not bound to any compute instances.
* **Unassociated Elastic IPs (EIP):** Static public IPv4 addresses allocated but not attached to an active resource.
* **Idle Application Load Balancers (ALB):** Provisioned load balancers serving zero active targets.

## Prerequisites
To interact with and deploy this project locally, ensure the following utilities are installed:
* **Terraform** (v1.7.0 or greater)
* **AWS CLI** (Configured with appropriate access credentials)
* **Python 3.x**
* **uv** (Extremely fast Python package installer and resolver)

## Project Structure
```text
.
├── custodian-policies/          # Modular Cloud Custodian rules
│   ├── data/                    # JSON metadata (e.g., tag allowlisting)
│   └── policies/                # YAML policies segregated by AWS service (ebs, ec2, vpc)
├── docs/                        # Remediation guides and audit reports
├── scripts/                     # Custom automation scripts (e.g., EBS Garbage Collector)
└── terraform/                   # Infrastructure as Code deployments
    ├── 00-bootstrap-bucket/     # Remote state configuration
    ├── 01-wasteful-resources/   # Deliberate waste provisioner
    ├── 02-governance/           # Future governance deployment
    ├── 03-optimization/         # Future optimization modifications
    └── modules/                 # Reusable networking and compute modules
```

## Usage

### 1. Infrastructure Deployment (Terraform)
To simulate the wasteful environment, initialize and apply the Terraform configuration. Ensure your AWS credentials and region are correctly configured in your environment.

```bash
cd terraform/01-wasteful-resources
terraform init
terraform plan
terraform apply
```

### 2. Install Cloud Custodian
The project uses Cloud Custodian (`c7n`) for serverless cloud management. We recommend installing it globally in an isolated environment using `uv`:

```bash
uv tool install c7n
```

### 3. Auditing and Remediation (Cloud Custodian)
Once installed, policies are executed through the `uv` tool to manage the isolated environment natively and safely.

**Validate the policies:**
```bash
uv tool run --from c7n custodian validate custodian-policies/policies/**/*.yml
```

**Execute a Dry Run (Audit Only):**
This operation scans the AWS account against the policies and logs matching resources into the `./out` directory without modifying state.
```bash
uv tool run --from c7n custodian run --dryrun --region <YOUR_REGION> --profile <YOUR_PROFILE> -s ./out custodian-policies/policies/
```

**Execute Tagging/Deletion:**
Removing the `--dryrun` flag will apply the actions defined in the policies (e.g., marking resources for deletion in 2 days).
```bash
uv tool run --from c7n custodian run --region <YOUR_REGION> --profile <YOUR_PROFILE> -s ./out custodian-policies/policies/
```

## Clean Up (Teardown)
To avoid unnecessary cloud charges, ensure all provisioned resources are destroyed when testing is complete. While Cloud Custodian will clean up marked resources autonomously via policy, you can fully destroy the simulated environment using Terraform:

```bash
cd terraform/01-wasteful-resources
terraform destroy
```