resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.application_name}-${var.vpc_name}"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_block_1
  availability_zone = var.aws_region
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_block_2
  availability_zone = var.aws_region
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.application_name}-internal-gateway"
  }
  
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.application_name}-route-table"
  }
  
}

resource "aws_route_table_association" "route_association_a" {
  subnet_id = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.route_table.id
  
}

resource "aws_route_table_association" "route_association_b" {
  subnet_id = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.route_table.id
  
}

resource "aws_route" "route" {
  route_table_id = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gateway.id
  
}

resource "aws_security_group" "ssh" {
  name_prefix   = var.aws_security_group_ssh
  vpc_id        = aws_vpc.vpc.id
  tags = {
      Name = "${var.application_name}-${var.aws_security_group_ssh}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http" {
  name_prefix   = var.aws_security_group_http
  vpc_id        = aws_vpc.vpc.id
  tags = {
      Name = "${var.application_name}-${var.aws_security_group_http}"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}