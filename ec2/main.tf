data "aws_ami" "latest-ami-image" {
  most_recent = true
  owners      = ["amazon"] # Ubuntu22
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "local_public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = var.cluster_name
  public_key = tls_private_key.local_public_key.public_key_openssh

  tags = var.resource_tags
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.latest-ami-image.id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.vpc_sg_ids]
  availability_zone      = var.az_one

  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion_key_pair.key_name

  tags = merge(var.resource_tags, {
    Name = "${var.cluster_name}-bastion"
  })

  user_data = file("${path.module}/scripts/init.sh")
}

resource "local_file" "private_key" {
  content  = tls_private_key.local_public_key.private_key_pem
  filename = pathexpand("~/.ssh/${var.cluster_name}.pem")

  provisioner "local-exec" {
    command = "chmod 400 ${pathexpand("~/.ssh/${var.cluster_name}.pem")}"
  }
}