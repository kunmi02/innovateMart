variable "name" {
  type        = string
  description = "Base name for resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where databases will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for database subnet group"
}

variable "eks_security_group_id" {
  type        = string
  description = "Security group ID of the EKS cluster"
}
