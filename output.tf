output "ami_id" {
  value = module.ec2.aws_ami_id
}
output "ami_name" {
  value = module.ec2.aws_ami_name
}
output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}
output "igw_id" {
	value = module.gateway_rt.id
}
output "sg_id" {
  value = module.security_group.id
}
output "subnet_id" {
	value = module.subnet.id
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}