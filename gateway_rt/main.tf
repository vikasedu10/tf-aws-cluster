resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = var.resource_tags
}

resource "aws_route_table" "route-table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = var.resource_tags
}

resource "aws_route_table_association" "assiciate-rtb-subnet" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.route-table.id
}
