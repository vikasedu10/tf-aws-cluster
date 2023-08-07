resource "aws_subnet" "subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr
  availability_zone = var.az_one
  tags = var.resource_tags
}
