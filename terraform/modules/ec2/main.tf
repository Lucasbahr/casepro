resource "aws_key_pair" "key" {
    key_name =  "key"
    public_key = file("~/.ssh/aws-machine.pub")
}

resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.key.key_name 
  associate_public_ip_address = true
  security_groups = [var.aws_security_group_ssh, var.aws_security_group_http]
  tags = {
    Name = "${var.application_name}-${var.aws_instance}"
  }
}