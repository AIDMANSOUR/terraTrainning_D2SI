# AWS provider
provider "aws" {
  region = "${var.aws_region}"
}

###### VPC ######
resource "aws_vpc" "labs1_vpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "dedicated"

  tags = {
    Name = "labs1-VPC"
  }
}

###### Subnet 2 ######
resource "aws_subnet" "labs1" {
  count = 2
  cidr_block        = "${element(var.subnet_cidr, count.index)}"
  availability_zone = "${element(var.aws_azs, count.index)}"
  vpc_id            = "${aws_vpc.labs1_vpc.id}"

  tags {
    Name = "${element(var.vpc_subnet_names, count.index)}"
  }
}

###### IGW ######
resource "aws_internet_gateway" "labs1_igw" {
  vpc_id = "${aws_vpc.labs1_vpc.id}"

  tags = {
    Name = "labs1-IGW"
  }
}

###### Route Table ######
resource "aws_route_table" "labs1_rt" {
  vpc_id = "${aws_vpc.labs1_vpc.id}"

  route {
    cidr_block = "${var.route_cidr}"
    gateway_id = "${aws_internet_gateway.labs1_igw.id}"
  }

  tags {
    Name = "labs1-route-table"
  }
}

###### Route table association with public subnets ######
resource "aws_route_table_association" "subnets" {
  count          = "${length(var.subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.labs1.*.id, count.index)}"
  route_table_id = "${aws_route_table.labs1_rt.id}"
}