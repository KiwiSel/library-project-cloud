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