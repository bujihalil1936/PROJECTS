terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.38.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#VPC
resource "aws_vpc" "Capstone-VPC" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env_prefix}-VPC"
  }
}

#SUBNETS (This VPC has two Public and Private Subnets within AZ-1A/AZ-1B)

resource "aws_subnet" "Public1A" {
  vpc_id            = aws_vpc.Capstone-VPC.id
  availability_zone = var.AZ_1A
  cidr_block        = var.Public1a
  tags = {
    Name = "${var.env_prefix}-Pub1a"
  }
}

resource "aws_subnet" "Private1A" {
  vpc_id            = aws_vpc.Capstone-VPC.id
  availability_zone = var.AZ_1A
  cidr_block        = var.Private1a
  tags = {
    Name = "${var.env_prefix}-Pri1a"
  }
}

resource "aws_subnet" "Public1B" {
  vpc_id            = aws_vpc.Capstone-VPC.id
  availability_zone = var.AZ_1B
  cidr_block        = var.Public1b
  tags = {
    Name = "${var.env_prefix}-Pub1b"
  }
}

resource "aws_subnet" "Private1B" {
  vpc_id            = aws_vpc.Capstone-VPC.id
  availability_zone = var.AZ_1B
  cidr_block        = var.Private1b
  tags = {
    Name = "${var.env_prefix}-Pri1b"
  }
}
#İGW 
resource "aws_internet_gateway" "Capstone-İGW" {
  vpc_id = aws_vpc.Capstone-VPC.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}
#ROUTE TABLES
resource "aws_route_table" "Capstone-PublicRT" {
  vpc_id = aws_vpc.Capstone-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Capstone-İGW.id
  }
  tags = {
    Name = "${var.env_prefix}-PublicRT"
  }
}

resource "aws_route_table" "Capstone-PrivateRT" {
  vpc_id = aws_vpc.Capstone-VPC.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.Capstone-NAT-instance.id
  }

  tags = {
    Name = "${var.env_prefix}-PrivateRT"
  }
}
#ROUTE TABLES ASSOCİATİON

resource "aws_route_table_association" "Public1A-assoc" {
  subnet_id      = aws_subnet.Public1A.id
  route_table_id = aws_route_table.Capstone-PublicRT.id
}

resource "aws_route_table_association" "Private1A-assoc" {
  subnet_id      = aws_subnet.Private1A.id
  route_table_id = aws_route_table.Capstone-PrivateRT.id
}

resource "aws_route_table_association" "Public1B-assoc" {
  subnet_id      = aws_subnet.Public1B.id
  route_table_id = aws_route_table.Capstone-PublicRT.id
}

resource "aws_route_table_association" "Private1B-assoc" {
  subnet_id      = aws_subnet.Private1B.id
  route_table_id = aws_route_table.Capstone-PrivateRT.id
}

#VPC ENDPOİNT

resource "aws_vpc_endpoint" "Capstone-s3endpoint" {
  vpc_id            = aws_vpc.Capstone-VPC.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.us-east-1.s3"
  route_table_ids   = [aws_route_table.Capstone-PrivateRT.id]
  tags = {
    Name = "${var.env_prefix}-s3endpoint"
  }
}
