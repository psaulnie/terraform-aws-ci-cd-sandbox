terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_default_vpc" "default" {
   tags = {
     Name = "Default VPC"
   }
}

resource "aws_default_security_group" "default" {
   vpc_id      = "${aws_default_vpc.default.id}"
 ingress {
     # TLS
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks     = ["0.0.0.0/0"]
   }
 egress {
     from_port       = 0
     to_port         = 0
     protocol        = "-1"
     cidr_blocks     = ["0.0.0.0/0"]
   }
 }

resource "aws_instance" "app_server" {
  ami           = "ami-007ec828a062d87a5"
  instance_type = "t2.micro"
  key_name      = "tf-key-pair"

  tags = {
    Name = "TerraformUbuntuInstance"
  }
}
