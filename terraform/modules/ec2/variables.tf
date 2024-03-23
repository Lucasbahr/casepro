variable "aws_region" {
  description = "AWS  regiao"
  default     = "sa-east-1"
}

variable "instance_type" {
  description = "tipo da instancia"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "imagem da instancia"
  default     = "ami-0c101f26f147fa7fd" 
}

variable "aws_instance" {
  default = "example-ec2-instance"
  
}

variable "application_name" {
  default = "casepro"
  
}

variable "subnet_id" {
  
}

variable "aws_security_group_ssh" {
  
}

variable "aws_security_group_http" {
  
}