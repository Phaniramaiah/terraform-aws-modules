# terraform-aws-modules

Reusable Terraform modules for running containerised web applications on AWS:
a highly available VPC, ECR, an HTTPS Application Load Balancer, an ECS Fargate
cluster and service with autoscaling, and a hardened S3 bucket with lifecycle
tiering. The [`examples/complete`](examples/complete) stack wires them together.

```
                    Route 53
                       │
               ┌───────▼────────┐   HTTP → HTTPS redirect
  Internet ───►│  ALB (public)  │   TLS 1.3 policy, ACM certificate
               └───────┬────────┘
                       │ host-based listener rule
      ┌────────────────▼────────────────┐
      │  ECS Fargate service (private)  │  rolling deploys, circuit breaker
      │  autoscaling on CPU, 2+ AZs     │  secrets from Secrets Manager
      └───────┬──────────────────┬──────┘
              │ NAT gateway      │ S3 gateway endpoint
              ▼                  ▼
          ECR, APIs          S3 (encrypted, TLS-only, lifecycle)
```

## Modules

| Module | What it creates |
| --- | --- |
| [`vpc`](modules/vpc) | VPC across 2–4 AZs, public and private subnets, NAT (shared or per-AZ), S3 gateway endpoint, VPC flow logs to CloudWatch, locked-down default security group |
| [`ecr`](modules/ecr) | Repositories with scan-on-push, immutable tags, encryption and lifecycle cleanup; optional cross-account pull policy |
| [`alb`](modules/alb) | Internet-facing ALB, HTTP→HTTPS redirect, TLS 1.3 listener, invalid-header dropping, optional access logs |
| [`ecs-cluster`](modules/ecs-cluster) | Fargate cluster with Container Insights and an optional Fargate Spot capacity mix |
| [`ecs-service`](modules/ecs-service) | Task definition, least-privilege execution and task roles, CloudWatch log group, target group, listener rule, deployment circuit breaker with rollback, CPU target-tracking autoscaling |
| [`s3-bucket`](modules/s3-bucket) | Private bucket: public access block, owner-enforced objects, versioning, SSE-S3 or KMS, TLS-only policy, IA → Glacier IR lifecycle, multipart cleanup |

## Usage

```hcl
module "vpc" {
  source = "github.com/Phaniramaiah/terraform-aws-modules//modules/vpc?ref=main"

  name     = "shop-prod"
  az_count = 3
}
```

Run the full example:

```bash
cd examples/complete
cp backend.hcl.example backend.hcl            # point at your state bucket
cp terraform.tfvars.example terraform.tfvars  # fill in your values
terraform init -backend-config=backend.hcl
terraform plan -out=release.tfplan
terraform apply release.tfplan
```

## Design choices

- **No secrets in code or state inputs.** Containers receive secrets by ARN from
  Secrets Manager or SSM; only the execution role can read them.
- **Least privilege by default.** Tasks only accept traffic from the ALB security
  group, the ALB only forwards inside the VPC, and the default security group
  denies everything.
- **Safe deployments.** Rolling updates keep 100% healthy capacity, and the ECS
  circuit breaker rolls back failed releases automatically.
- **Cost-aware.** Single NAT gateway outside production, Graviton (`ARM64`) tasks,
  Fargate Spot for non-prod, S3 lifecycle tiering and ECR image cleanup.
- **State.** S3 backend with native lock files (`use_lockfile`, Terraform 1.10+).

## CI

Every push runs `terraform fmt`, `terraform validate` on each module, `tflint`
with the AWS ruleset, and a Trivy IaC security scan.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | >= 1.6 (examples: >= 1.10) |
| AWS provider | >= 6.0, < 7.0 |

## License

MIT
