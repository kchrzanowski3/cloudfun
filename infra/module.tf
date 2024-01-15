
/*
# used for testing 

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "demo-dev"

  cidr = "10.10.0.0/16"
  azs             = ["us-east-1d", "us-east-1e"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.3.0/24", "10.10.4.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "module-vpc"
  }
}
*/