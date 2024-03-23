output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet__a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "subnet__b_id" {
  value = aws_subnet.public_subnet_b.id
}

output "aws_security_group_ssh" {
  value =aws_security_group.ssh.id
  
}

output "aws_security_group_http" {
  value =aws_security_group.ssh.id
  
}