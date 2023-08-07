output "aws_ami_id" {
  value = data.aws_ami.latest-ami-image.id
}
output "aws_ami_name" {
  value = data.aws_ami.latest-ami-image.name
}
output "aws_ami_description" {
  value = data.aws_ami.latest-ami-image.description
}
output "ec2_public_ip" {
  value = aws_instance.bastion.public_ip
}
