locals {
  cluster_name = "${var.cluster_id}-cls"
  resource_tags = {
    Name        = "${var.cluster_id}-cls"
    owner       = var.owner_tag
    environment = var.env
  }
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = local.cluster_name
  cidr            = var.vpc_cidr_block
  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = merge(
    local.resource_tags, {
      "kubernetes.io/cluster/${local.cluster_name}" : "shared"
    }
  )
  private_subnet_tags = merge(
    local.resource_tags, {
      "kubernetes.io/cluster/${local.cluster_name}" : "shared"
      "kubernetes.io/role/internal-elb" : 1
    }
  )
  public_subnet_tags = merge(
    local.resource_tags, {
      "kubernetes.io/cluster/${local.cluster_name}" : "shared"
      "kubernetes.io/role/elb" : 1
    }
  )
}

module "platform_eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true,
    }
  }

  subnet_ids = module.vpc.private_subnets # If subnet IDs not provided, need to provide control_plane_subnet_ids
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    my_node_group = {
      name           = local.cluster_name
      min_node_count = var.min_node_count
      max_node_count = var.max_node_count
      instance_type  = var.instance_type
      tags           = local.resource_tags
    }
  }

  iam_role_name        = local.cluster_name
  iam_role_description = "IAM Role for EKS cluster created using Terraform IaC"

  tags = local.resource_tags # This module level tags will be added to all underlying resources

}
data "aws_eks_cluster" "cluster" {
  name = module.platform_eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.platform_eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}