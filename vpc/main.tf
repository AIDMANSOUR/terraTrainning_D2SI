# AWS provider
provider "aws" {
  region = "${var.aws_region}"
}

###### VPC ######
resource "aws_vpc" "labs1_vpc" {
  cidr_block       = "172.23.0.0/16"
  instance_tenancy = "dedicated"

  tags = {
    Name = "labs1"
  }
}

###### Subnet ######
resource "aws_subnet" "labs1_public" {
  cidr_block        = "172.23.1.0/24"
  availability_zone = "${var.aws_region}a"
  vpc_id            = "${aws_vpc.labs1_vpc.id}"

  tags {
    Name = "Labs1"
  }
}

###### IGW ######
resource "aws_internet_gateway" "labs1_igw" {
  vpc_id = "${aws_vpc.labs1_vpc.id}"

  tags = {
    Name = "Labs1"
  }
}

###### Route Table ######
resource "aws_route_table" "labs1_rt" {
  vpc_id = "${aws_vpc.labs1_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.labs1_igw.id}"
  }

  tags {
    Name = "labs1"
  }
}

###### Route table association with public subnets ######
resource "aws_route_table_association" "labs1_art" {
  subnet_id      = "${aws_subnet.labs1_public.id}"
  route_table_id = "${aws_route_table.labs1_rt.id}"
}
