## Provider
provider "aws" {
  #profile = local.workspace["aws_profile"]
  region  = "us-east-1"
}

terraform {
  cloud {
    organization = "kylechrzanowski"

    workspaces {
        project = "cloudfun"
        name = "default-tf-workspace"
    }
  }
}