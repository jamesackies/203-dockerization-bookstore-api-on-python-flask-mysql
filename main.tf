terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# -------------------------------------------------------
# DATA SOURCES
# -------------------------------------------------------

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -------------------------------------------------------
# SECURITY GROUP
# -------------------------------------------------------

resource "aws_security_group" "bookstore_sg" {
  name        = "bookstore-sg"
  description = "Allow HTTP and SSH from anywhere"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bookstore-sg"
  }
}

# -------------------------------------------------------
# EC2 INSTANCE
# -------------------------------------------------------

resource "aws_instance" "bookstore_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bookstore_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user

    # Install Docker Compose
    curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Clone the application from GitHub
    # Replace the URL below with your actual GitHub repo URL
    cd /home/ec2-user
    git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git app
    cd app

    # Build and run the containers
    docker-compose up -d --build
  EOF

  tags = {
    Name = "Web Server of Bookstore"
  }
}

# -------------------------------------------------------
# OUTPUTS
# -------------------------------------------------------

output "bookstore_api_url" {
  value       = "http://${aws_instance.bookstore_server.public_dns}"
  description = "Bookstore Web API URL"
}

output "bookstore_public_ip" {
  value       = aws_instance.bookstore_server.public_ip
  description = "Bookstore EC2 Public IP"
}
