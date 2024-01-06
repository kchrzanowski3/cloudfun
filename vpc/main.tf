# file name: main.tf

## Main
resource "aws_vpc" "hellovpc" {
  cidr_block = local.workspace["cidr_block"]

  tags = {
    Name = terraform.workspace
  }
}