terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region"   { 
    type = string 
    default = "eu-west-1" 
}
variable "role_name" { 
    type = string 
    default = "gha-terraform-deployer" 
}

# GitHub OIDC provider (dynamic thumbprint)
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  tags = { Name = "GitHubActionsOIDC" }
}

# Trust policy restricted to your repo:
# - pushes to any branch (refs/heads/*)
# - pull_request events (subject format ends with :pull_request)
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:kunmi02/retail-store-sample-app:ref:refs/heads/*",
        "repo:kunmi02/retail-store-sample-app:ref:refs/tags/*",
        "repo:kunmi02/retail-store-sample-app:ref:refs/heads/gh-readonly-queue/*",
        "repo:kunmi02/retail-store-sample-app:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "gha_terraform" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = "Role assumed by GitHub Actions for Terraform in retail-store-sample-app"
  tags = { Project = "Project-Bedrock" }
}

# WARNING: For a real production account, replace with a tighter policy.
# This attaches AdministratorAccess for simplicity so Terraform can create all required infra.
resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.gha_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "role_arn" {
  value = aws_iam_role.gha_terraform.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
