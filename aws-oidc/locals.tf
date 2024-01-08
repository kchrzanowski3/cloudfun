## Locals
locals {
    env = {
        default = {
            aws_profile = "default"
            aws_region  = "us-east-1"
            organization = "kylechrzanowski"
        }
    }
    
    
    repo = {
        org = "kchrzanowski3"
        project = "cloudfun"
    }
    
    workspace = local.env["default"]
    
  
}
