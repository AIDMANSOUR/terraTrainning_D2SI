# AWS provider
provider "aws" {
  region = "${var.aws_region}"
}

data "terraform_remote_state" "rs-vpc"{ 
    backend = "s3"
    config {
        bucket = "my-tfstat-bucket"
        key = "vpc/terraform.tfstat" 
        region = "eu-west-1"
        }
}

resource "aws_security_group" "allow_all" {
    name = "allow_all"
    description = "Allow all inbound traffic"
    vpc_id = "${data.terraform_remote_state.rs-vpc.aws_labs1_vpc_id}"
    
   ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags{
      Name = "labs1-SG"
    }
  }

############
# SSH keys #

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  #contenu du fichier : ssh-keys/admin-user.pub
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbmFZE86YBxCLvfkdJnYlXiYYzq3mT4PAFG4SAREZKNj/1XL4/61K8HJZ8giDXiUhA7rWQvjRQZvAbd+YsxIlvs4ByVO06iQ1Stkuv8iZmPxd168/+xyuthcUNeAKhHtuwhu+cEa3C5g6Y+UtMQ+8ubL78J1Py6VG/KTH1a6nHPYNtcKf06PoM6nHiNUjfpQhA8WRS/ykk261KAMZdXPXph8PRXojpJPopaXj1kXPghh6nxKmjjTOKxxBxGNhJZyMgoeqA8KMc3hzj+Wtm9SnkY3bIVmEWpMEjP8Ii0yHVY21eh+y+iXgBHpKazGF1nhr7eRE08fOzODjrB+Bx6rGN aidmansour@MacBook-Pro-de-AIDMANSOUR.local"
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible-key"
# contenu du fichier : ssh-keys/ansible-user.pub
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvXsBDHcYcNbGHdyfrH6nr3bkJXb5rM6sb0ug13pqhsjMBBqZ/KxpwZyZpsgb8wpR1x17252v77fqyizKtUbH2KJchTiayIg+dH7suNmj0xjpZctYig6LJRzpdl849Ppi4jknRgKYswpBjcY/aA8DONtyipLk8jNnWpN3qeti6BFRxovzeJ5mJij5Xfc2T64FPZ7SJPdtCWcY9HCU/SDIeBjylB4xF2FocJp95fKmQX9ZohywzUZymIME7hTXqJtZWdSep3Q8FKWJc4fXNLcancxfou+/JsisVY5/u16SVaopd+2c6Fz5or9i/DomJtJwr35Yhw6gwI58v25Xhq7IJ aidmansour@MacBook-Pro-de-AIDMANSOUR.local"
}


data "aws_ami" "ubuntu" {
    most_recent = true

      filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
        } 

    owners = ["099720109477"] # Canonical
}

data "template_file" "template_labs" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars {
    username = "aidmansour"
  }
}

resource "aws_instance" "web" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.ansible.key_name}"  # assign ssh ansible key
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"] 
  user_data = "${data.template_file.template_labs.rendered}"
  subnet_id = "${data.terraform_remote_state.rs-vpc.aws_labs1_subnet}"
  
    tags {
      Name = "labs1-HelloWorld" }
}
