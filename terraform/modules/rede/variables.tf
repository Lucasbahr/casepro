variable "aws_region" {
  description = "AWS  regiao"
  default     = "sa-east-1"
}

variable "vpc_name" {
  description = "Nome do VPC"
  default     = "devops-test-vpc"
}

variable "subnet_cidr_block_1" {
  description = "CIDR block para subnet"
  default     = "10.0.0.0/25"
}

variable "subnet_cidr_block_2" {
  description = "CIDR block para subnet"
  default     = "10.0.0.128/25"
}

variable "aws_security_group_http" {
  default = "dev-test-http"
}

variable "aws_security_group_ssh" {
  default = "dev-test-ssh"
  
}

variable "application_name" {
  default = "casepro"
  
}