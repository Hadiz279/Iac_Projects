# Hazy_Coderz Terraform_Tasks 

# IaC Projects

## Using Terraform, launch an EC2 instance in `us-east-1`, with a specific AMI, instance type, and a custom security group allowing ssh and http,https inbound and outbound traffic.

provider "aws" { 
	region = "us-east-1"
} 

resource "aws_instance" "my_linux_server" {
	ami = "ami-020cba7c55df1f615" 
	instance_type = "t3.micro"
	vpc_security_group_ids = [aws_security_group.my_linux_sg.id]

	tags = {
	Name = "LinuxServer"
	}
}

resource "aws_security_group" "my_linux_sg" {
	name = "my_linux_sg"
	description = "Allow SSH,HTTP and HTTPS inbound traffic"
	
	ingress {
	description = "Allow SSH from anywhere"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
	description = "Allow http from anywhere"
	from_port = 80
	to_port = 80
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
	description = "Allow https from anywhere"
	from_port = 443
	to_port = 443
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
	description = "Allow HTTPS outbound"
	from_port = 443
	to_port = 443
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "my_linux_sg"
	}
}
