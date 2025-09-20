module "vpc" {
  source     = "./modules/vpc"
  name       = var.name
  cidr_block = "10.0.0.0/16"
  az_count   = 3
}

module "eks" {
  source             = "./modules/eks"
  name               = var.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  cluster_version    = "1.30"
  desired_size       = 3
  min_size           = 3
  max_size           = 6
}

# Providers for k8s
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

module "iam" {
  source                 = "./modules/iam"
  cluster_oidc_provider  = module.eks.oidc_provider_arn
  cluster_oidc_url       = module.eks.oidc_provider_url
  dev_readonly_user_name = "innovatemart-dev-viewer"
  eks_cluster_name       = module.eks.cluster_name
}

module "databases" {
  source                = "./modules/databases"
  name                  = var.name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id
}
