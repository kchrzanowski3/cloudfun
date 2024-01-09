# file name: main.tf

## virtual private cloud
resource "aws_vpc" "hellovpc" {
  cidr_block = local.workspace["cidr_block"]

  tags = {
    Name = terraform.workspace
  }
}

#stand up an ubuntu image created in packer
resource "aws_instance" "web" {
  ami           = "ami-00c9800eb7c3cbe61"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}


