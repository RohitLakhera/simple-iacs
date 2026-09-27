terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

provider "aws" {
  region = var.aws_region
}

# Use the default VPC that every AWS account already has
data "aws_vpc" "default" {
  default = true
}

# Latest Amazon Linux 2023 image
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Allow web traffic (port 80) from anywhere
resource "aws_security_group" "web" {
  name        = "simple-iac-web-sg"
  description = "Allow HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# One small web server
resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y httpd
    echo "<h1>Hello from Terraform + Jenkins on AWS!</h1>" > /var/www/html/index.html
    systemctl enable --now httpd
  EOT

  tags = {
    Name = "simple-iac-web"
  }
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}
