data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  resource_tags = {
    Name        = "${var.cluster_id}-${var.env}-cluster"
    owner       = var.owner_tag
    environment = var.env
  }
}
module "vpc" {
  source = "./vpc"
  cluster_id = var.cluster_id
  resource_tags = local.resource_tags
  cidr = var.vpc_cidr_block
}

module "subnet" {
  source = "./subnet"
  cluster_id = var.cluster_id
  resource_tags = local.resource_tags
  vpc_id = module.vpc.vpc_id
  az_one = data.aws_availability_zones.available.names[0]
  cidr = var.vpc_cidr_block
}

module "gateway_rt" {
  source = "./gateway_rt"
  cluster_id = var.cluster_id
  resource_tags = local.resource_tags
  vpc_id = module.vpc.vpc_id
  subnet_id = module.subnet.id
}

module "security_group" {
  source = "./security_group"
  cluster_id = var.cluster_id
  resource_tags = local.resource_tags
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./ec2"
  cluster_id = var.cluster_id
  resource_tags = local.resource_tags
  instance_type = var.instance_type
  subnet_id = module.subnet.id
  vpc_sg_ids = module.security_group.id
  az_one = data.aws_availability_zones.available.names[0]
}