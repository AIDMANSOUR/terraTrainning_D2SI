variable "aws_region" {
  default = "eu-west-1"
  description = "Region par defaut"
} # UE-Irland

variable "aws_azs" {
  type = "list"
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "vpc_cidr" {
	default = "172.23.0.0/16"
  description = " cidr block du vpc"
}

variable "subnet_cidr" {
  type = "list"
	default = ["172.23.100.0/24", "172.23.200.0/24"]
  description = " cidr block du subnet"
}

variable "vpc_subnet_names" { 
  type = "list" 
  default = ["labs-pub-1a", "labs-pub-1b"] 
}

variable "route_cidr" {
	default = "0.0.0.0/0"
  description = " cidr block de la route table"
}