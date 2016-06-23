variable "num_workstations"        { }
variable "key_name"                { }
variable "public_key"              { }
variable "sg"                      { }
variable "subnet"                  { }

provider "aws" {
    region = "eu-west-1"
}

resource "aws_key_pair" "vault-workshop-key" {
  key_name = "${var.key_name}"
  public_key = "${var.public_key}"
  lifecycle { create_before_destroy = true }
}

resource "aws_instance" "workstation" {
    count = "${var.num_workstations}"
    ami = "ami-566df425"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = "${var.subnet}"
    vpc_security_group_ids = [
      "${var.sg}"
    ]
    key_name = "${var.key_name}"
    user_data = "${file("user_data.txt")}"
    tags {
       Name = "vault-workshop-${count.index}"
    }
}

