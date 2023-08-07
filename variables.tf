terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  shared_credentials_files = ["~/.aws/credentials"]
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
variable "owner_tag" {
  default = "vikasedu10"
}
variable "cluster_id" {
  default = "DFK32534KOD001"
}
variable "env" {
  default = "dev"
}
variable "instance_type" {
default = "t3.medium"
}
variable "min_node_count"{
default = "2"
}
variable "max_node_count"{
default = "4"
}