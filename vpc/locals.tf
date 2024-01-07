## Locals
locals {
    env = {
        default = {
            aws_profile = "default"
            aws_region  = "us-east-1"
            cidr_block = "10.0.0.0/20"
        }
    }
    
    repo = {
        org = "kchrzanowski3"
        project = "cloudfun"
    }
    
    workspace = local.env["default"]
    
  
}
