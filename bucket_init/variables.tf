variable "aws_region" {
  default = "eu-west-1"
  description ="Region par defaut"
} # UE-Irland

variable "vpc_cidr" {
	default = "172.23.0.0/16"
  description = " cidr block du vpc"
}

variable "subnet_cidr" {
	default = "172.23.100.0/24"
  description = " cidr block du subnet"
}

variable "route_cidr" {
	default = "0.0.0.0/0"
  description = " cidr block de la route table"
}