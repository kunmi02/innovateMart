# Bootstrap: GitHub OIDC + Deployer Role

Creates:
- An **OIDC provider** for GitHub Actions: `https://token.actions.githubusercontent.com`
- An IAM role **gha-terraform-deployer**, trusted **only** for your repo:
  `kunmi02/retail-store-sample-app` (pushes to any branch + pull_request events).

> Region default: `eu-west-1`

## Usage

```bash
cd bootstrap/github-oidc
terraform init
terraform apply -auto-approve
```

Outputs:
- `role_arn` → Use this in `.github/workflows/infra.yml` under `role-to-assume`.
- `oidc_provider_arn` → Informational.

## Security Notes
- The trust policy is locked to your repo and only allows:
  - `repo:kunmi02/retail-store-sample-app:ref:refs/heads/*`
  - `repo:kunmi02/retail-store-sample-app:pull_request`
- The policy attachment uses **AdministratorAccess** for simplicity. In production, replace with a least-privilege policy that covers only the services your Terraform requires (EKS, VPC, IAM, EC2, ELB, CloudWatch, etc.).
