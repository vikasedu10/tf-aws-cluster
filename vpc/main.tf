resource "aws_vpc" "vpc" {
  instance_tenancy = "default"
  cidr_block       = var.cidr

  tags = var.resource_tags
}
