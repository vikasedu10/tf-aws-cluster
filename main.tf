locals {
  cluster_name = "${var.cluster_id}-cls"
  resource_tags = {
    Name        = "${var.cluster_id}-cls"
    owner       = var.owner_tag
    environment = var.env
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = local.cluster_name
  cidr            = var.vpc_cidr_block
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = merge(
    local.resource_tags, {
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    }
  )
  private_subnet_tags = merge(
    local.resource_tags, {
      Name                                          = "${local.cluster_name}-private"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"             = 1
    }
  )
  public_subnet_tags = merge(
    local.resource_tags, {
      Name                                          = "${local.cluster_name}-public"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                      = 1
    }
  )
  default_security_group_tags = merge(
    local.resource_tags, {
      Name = "${local.cluster_name}-default"
    }
  )
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # If subnet IDs not provided, need to provide control_plane_subnet_ids

  eks_managed_node_groups = {
    one = {
      my_node_group = {
        name           = "${local.cluster_name}-one"
        min_node_count = var.min_node_count
        max_node_count = var.max_node_count
        instance_type  = var.instance_type
        tags = merge(local.resource_tags, {
          Name = "${local.cluster_name}-one"
        })
      }
    }
    two = {
      my_node_group = {
        name           = "${local.cluster_name}-two"
        min_node_count = var.min_node_count
        max_node_count = var.max_node_count
        instance_type  = var.instance_type
        tags = merge(local.resource_tags, {
          Name = "${local.cluster_name}-two"
        })
      }
    }
  }

  iam_role_name        = local.cluster_name
  iam_role_description = "IAM Role for EKS cluster created using Terraform IaC"

  tags = local.resource_tags # This module level tags will be added to all underlying resources
}

module "irsa-ebs-csi" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "${module.eks.cluster_name}-AmazonEKSTFEBSCSIRole"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = merge(local.resource_tags, {
    "eks_addon" = "ebs-csi"
  })
}

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name
# }
# data "aws_eks_cluster_auth" "cluster_auth" {
#   name = module.eks.cluster_name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   token                  = data.aws_eks_cluster_auth.cluster_auth.token
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
# }

module "ec2" {
  source        = "./ec2"
  cluster_name  = local.cluster_name
  resource_tags = local.resource_tags
  instance_type = var.bastion_instance_type
  subnet_id     = module.vpc.public_subnets[0]
  vpc_sg_ids    = module.vpc.default_security_group_id
  az_one        = data.aws_availability_zones.available.names[0]
}