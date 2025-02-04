variable "vpc_cidr" {}
variable "vpc_name" {}
variable "subnet_cidrs" {}
variable "availability_zones" {}
variable "subnet_name" {}
variable "sg_name" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "${var.subnet_name}-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "${var.subnet_name}-2"
  }
}

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  name   = var.sg_name

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}