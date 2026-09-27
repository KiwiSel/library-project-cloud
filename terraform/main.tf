terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "library" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "library-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.library.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "library-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.library.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "library-private-subnet"
  }
}

resource "aws_internet_gateway" "library" {
  vpc_id = aws_vpc.library.id

  tags = {
    Name = "library-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.library.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.library.id
  }

  tags = {
    Name = "library-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.library.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "library-private-subnet-b"
  }
}

resource "aws_db_subnet_group" "library" {
  name = "library-db-subnet-group"

  subnet_ids = [
    aws_subnet.private.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "library-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "library-rds-security-group"
  description = "Security group for the library RDS database"
  vpc_id      = aws_vpc.library.id

  tags = {
    Name = "library-rds-security-group"
  }
}

resource "aws_security_group" "app" {
  name        = "library-app-security-group"
  description = "Security group for the library application"
  vpc_id      = aws_vpc.library.id

  tags = {
    Name = "library-app-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.app.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Allow PostgreSQL traffic from the library application"
}