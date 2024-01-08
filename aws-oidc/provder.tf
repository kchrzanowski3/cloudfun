## Provider
provider "aws" {
  #profile = local.workspace["aws_profile"]
  region  = local.env.default.aws_region
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