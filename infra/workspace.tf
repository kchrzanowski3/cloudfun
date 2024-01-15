##
## WORKSPACE DEFINITIONS
##

data "aws_workspaces_bundle" "value_windows_10" {
  bundle_id = "wsb-362t3gdrt" # free tier elgible (standard tier) with Windows 10 (English)
}

#the actual workspace being created
resource "aws_workspaces_workspace" "example" {
  directory_id = aws_workspaces_directory.cloudfun.id
  bundle_id    = data.aws_workspaces_bundle.value_windows_10.id
  user_name    = "Admin"

  root_volume_encryption_enabled = false
  user_volume_encryption_enabled = false

  workspace_properties {
    compute_type_name                         = "STANDARD"
    user_volume_size_gib                      = 50
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }

  depends_on = [ 
    aws_iam_role.workspaces_default
    #aws_workspaces_directory.cloudfun
   ]

  tags = {
    Name = "aws_workspaces_workspace.example"
  }
}

#workspace directory is used to store and manage information for our Amazon workspace and users
resource "aws_workspaces_directory" "cloudfun" {
  directory_id = aws_directory_service_directory.example.id
  subnet_ids = [
    aws_subnet.az1-private.id,
    aws_subnet.az2-private.id
  ]

  tags = {
    Example = true
    Name = "aws_workspaces_directory.cloudfun"
  }

  lifecycle {
    prevent_destroy = false  # Allow destruction even with workspaces
  }

  depends_on = [
    aws_iam_role_policy_attachment.workspaces_default_service_access,
    aws_iam_role_policy_attachment.workspaces_default_self_service_access
  ]

}

##aws roles to create the workspace
data "aws_iam_policy_document" "workspaces" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["workspaces.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workspaces_default" {
  name               = "workspaces_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.workspaces.json
}

resource "aws_iam_role_policy_attachment" "workspaces_default_service_access" {
  role       = aws_iam_role.workspaces_default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess"
}

resource "aws_iam_role_policy_attachment" "workspaces_default_self_service_access" {
  role       = aws_iam_role.workspaces_default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
}


##
## WORKSPACE VPC NETWORK AND 4 SUBNETS (2 PUB 2 PRIVATE)
##

##VPC and subnet network definitions
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
      Name = "aws_vpc.example"
  }
}

resource "aws_subnet" "az1-pub" {
  vpc_id            = aws_vpc.example.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.7.0/24"
  map_public_ip_on_launch = true  # Enables public IP assignment
  tags = {
      Name = "aws_subnet.az1-pub"
  }
}

resource "aws_subnet" "az2-pub" {
  vpc_id            = aws_vpc.example.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.4.0/24"
  map_public_ip_on_launch = true  # Enables public IP assignment
  tags = {
      Name = "aws_subnet.az2-pub"
  }
}

resource "aws_subnet" "az1-private" {
  vpc_id            = aws_vpc.example.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.5.0/24"
  
  
  tags = {
      Name = "aws_subnet.az1-private"
  }
}

resource "aws_subnet" "az2-private" {
  vpc_id            = aws_vpc.example.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.2.0/24"

  tags = {
      Name = "aws_subnet.az2-private"
  }
}


#internet gateway to enable access to internet access from VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example.id
  
  tags = {
    Name = "aws_internet_gateway.gw"
  }
  #depends_on = [ aws_workspaces_workspace.example ]
}


#nat gateways to enable access to private networks from vpc
resource "aws_nat_gateway" "example_a" {
  allocation_id = aws_eip.nat_gateway_eip_a.id
  subnet_id     = aws_subnet.az1-pub.id

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [ aws_internet_gateway.gw ]

  tags = {
    Name = "aws_nat_gateway.example_a"
  }
}

#elastic ip addresses for the NAT gateway
resource "aws_eip" "nat_gateway_eip_a" {
  domain = "vpc"  # Ensure the EIP is created within the VPC
  tags = {
    Name = "aws_eip.nat_gateway_eip_a"
  }
  
  depends_on = [ aws_internet_gateway.gw ]
}

resource "aws_eip" "igw_eip" {
  domain = "vpc"  # Ensure the EIP is created within the VPC
  tags = {
    Name = "aws_eip.igw_eip"
  }

}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"  # Route all other traffic to the nat gateway a
    nat_gateway_id = aws_nat_gateway.example_a.id  # Target the nat gateway
  }
  route {
    cidr_block = aws_vpc.example.cidr_block  # Route all local traffic locally
    gateway_id = "local" 
  }

  tags = {
    Name = "aws_route_table.private_route_table"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"  # Route all traffic
    gateway_id = aws_internet_gateway.gw.id  # Target the internet gateway
  }
  route {
    cidr_block = aws_vpc.example.cidr_block   # Route all local traffic locally
    gateway_id = "local" 
  }

  tags = {
    Name = "aws_route_table.public_route_table"
  }
}

resource "aws_route_table_association" "nat_subnet_association_pub1" {
  subnet_id      = aws_subnet.az1-pub.id  # Subnet where the NAT gateway is located
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "nat_subnet_association_pub2" {
  subnet_id      = aws_subnet.az2-pub.id  # Subnet where the NAT gateway is located
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "nat_subnet_association_private1" {
  subnet_id      = aws_subnet.az1-private.id  # Subnet where the NAT gateway is located
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "nat_subnet_association_private2" {
  subnet_id      = aws_subnet.az2-private.id  # Subnet where the NAT gateway is located
  route_table_id = aws_route_table.private_route_table.id
}


#update the DHCP( Dynamic Host Configuration Protocol ) Options in the VPC to join machines to the directory.
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = aws_directory_service_directory.example.dns_ip_addresses
  domain_name = "demolocal"
  tags = {
    Name = "aws_vpc_dhcp_options.dns_resolver"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id = aws_vpc.example.id
    dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
  }
  




