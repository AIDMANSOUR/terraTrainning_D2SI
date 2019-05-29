# AWS provider
provider "aws" {
  region = "${var.aws_region}"
}

data "terraform_remote_state" "rs-vpc"{ 
    backend = "s3"
    config {
        bucket = "my-tfstat-bucket1"
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
    ingress {
        from_port = 22
        to_port = 22
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
        values = ["pretty_ami_ali*"]
        } 

    owners = ["self"] # Canonical
}

data "template_file" "template_labs" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars {
    username = "aidmansour"
  }
}
/*
resource "aws_instance" "web" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3.micro"
  key_name = "${aws_key_pair.ansible.key_name}"  # assign ssh ansible key
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"] 
  user_data = "${data.template_file.template_labs.rendered}"
  subnet_id = "${data.terraform_remote_state.rs-vpc.aws_labs1_subnet}"
  associate_public_ip_address = "true"
  
    tags {
      Name = "labs1-HelloWorld" }
}
*/

resource "aws_launch_configuration" "webappconf" {
  name_prefix          = "webapp_config"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.allow_all.id}"] 
  key_name = "ansible-key"
  user_data = "${data.template_file.template_labs.rendered}"

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_autoscaling_group" "webappscal" {
  vpc_zone_identifier =["${data.terraform_remote_state.rs-vpc.aws_labs1_subnet[0]}","${data.terraform_remote_state.rs-vpc.aws_labs1_subnet[1]}"]
  name = "asg-${aws_launch_configuration.webappconf.name}"
  max_size           = 1
  min_size           = 1
  health_check_grace_period = 300
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.webappconf.name}"
  load_balancers = ["${aws_elb.webappelb.id}"]

  tags = [
    {
      key = "Name"
      value = "autoscaledserver"
      propagate_at_launch = true
    }
  ]
   lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_elb" "webappelb" {
  name = "web-elb"
  subnets = ["${data.terraform_remote_state.rs-vpc.aws_labs1_subnet[0]}","${data.terraform_remote_state.rs-vpc.aws_labs1_subnet[1]}"]
  security_groups = ["${aws_security_group.allow_all.id}"]
  ## Loadbalancer configuration
  listener {
  instance_port = 80
  instance_protocol = "http"
  lb_port = 80
  lb_protocol = "http"
  }

  health_check {
  healthy_threshold = 2
  unhealthy_threshold = 2
  timeout = 2
  target = "HTTP:80/"
  interval = 5
  }
}
