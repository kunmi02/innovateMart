variable "dev_readonly_user_name" { type = string }
variable "cluster_oidc_provider"  { type = string }
variable "cluster_oidc_url"       { type = string }
variable "eks_cluster_name"       { type = string }

resource "aws_iam_user" "dev_ro" {
  name = var.dev_readonly_user_name
}

data "aws_iam_policy_document" "dev_ro" {
  statement {
    actions = [
      "eks:Describe*","eks:List*","eks:AccessKubernetesApi",
      "logs:Describe*","logs:Get*","logs:List*","logs:FilterLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "dev_ro" {
  name        = "${var.dev_readonly_user_name}-policy"
  description = "Read-only EKS + CloudWatch Logs"
  policy      = data.aws_iam_policy_document.dev_ro.json
}

resource "aws_iam_user_policy_attachment" "dev_ro_attach" {
  user       = aws_iam_user.dev_ro.name
  policy_arn = aws_iam_policy.dev_ro.arn
}

resource "aws_iam_access_key" "dev_ro" {
  user = aws_iam_user.dev_ro.name
}

output "dev_ro_access_key_id"       { 
    value = aws_iam_access_key.dev_ro.id 
}
output "dev_ro_secret_access_key"   { 
    value = aws_iam_access_key.dev_ro.secret 
    sensitive = true 
}
