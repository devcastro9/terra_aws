terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "app_sg" {
  name        = "flask-app-sg"
  description = "Permite HTTP para la app y SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP app"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnet_ids.default.ids, 0)
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = merge(var.tags, { Name = "flask-app" })
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

output "public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.app.public_ip
}

output "public_dns" {
  description = "DNS público de la instancia EC2"
  value       = aws_instance.app.public_dns
}
