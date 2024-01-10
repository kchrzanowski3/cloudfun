# file name: main.tf

## virtual private cloud
resource "aws_vpc" "hellovpc" {
  cidr_block = local.workspace["cidr_block"]

  tags = {
    Name = terraform.workspace
  }
}

#filter the ami images to result in the ubuntu image created by packer
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-packer-cloudfun-*"]
  }
}

#stand up an ubuntu ec2 image created in packer
resource "aws_instance" "ubuntu-packer" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "ubuntu from packer"
  }
}


