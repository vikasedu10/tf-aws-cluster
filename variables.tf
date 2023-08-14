terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
}
variable "cluster_version" {
  default = "1.27"
}
variable "owner_tag" {
  default = "vikasedu10"
}
variable "cluster_id" {
  default = "DFK32002"
}
variable "env" {
  default = "dev"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
  default = "10.0.0.0/16"
}
variable "region" {
  default = "ap-south-1"
}
variable "private_subnets_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_subnets_cidr" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}


variable "instance_type" {
  default = "t3.small"
}
variable "bastion_instance_type" {
  default = "t3.small"
}
variable "min_node_count" {
  default = "1"
}
variable "max_node_count" {
  default = "3"
}