# AWS provider
provider "aws" {
  region = "${var.aws_region}"
}

###### VPC ######
resource "aws_vpc" "labs1" {
  cidr_block       = "172.23.0.0/16"
  instance_tenancy = "dedicated"

  tags = {
    Name = "labs1"
  }
}

###### Subnet ######
resource "aws_subnet" "web-public-2a" {
  cidr_block        = "172.23.1.0/24"
  availability_zone = "${var.aws_region}a"
  vpc_id            = "${aws_vpc.labs1.id}"

  tags {
    Name = "Labs1"
  }
}
