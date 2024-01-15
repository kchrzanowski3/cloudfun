##
## Active Directory Service
##

#aws managed directory service 
resource "aws_directory_service_directory" "example" {
  name     = "demo.local"
  password = "SuperSecret@123!"
  type     = "MicrosoftAD"
  edition = "Standard"

  vpc_settings {
    vpc_id = aws_vpc.example.id
    subnet_ids = [
      aws_subnet.az1-private.id,
      aws_subnet.az2-private.id
    ]
  }

  tags = {
      Name = "aws_directory_service_directory.example"
  }
}


##
## Server used to administer and manage AD
##

#image created by packer with ad management tools pre-installed
data "aws_ami" "ad-management-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ad-management-server-packer-*"]
  }
}

## set up a domain manager windows instance
resource "aws_instance" "domain_manager" {
  ami           = data.aws_ami.ad-management-ami.id  # Free tier eligible microsoft windows server 22 (check for latest)
  instance_type = "t2.micro"  # Free tier eligible instance type
  subnet_id = aws_subnet.az1-pub.id
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_ad_manager_profile.name
  vpc_security_group_ids = [aws_security_group.allow_rdp.id]

  # Optional: Add a key pair for SSH access
  key_name = aws_key_pair.windows-ad-manager-server.key_name  # Replace with your key pair name
  
  # Necessary for free tier eligibility
  tenancy = "default"

  tags = {
    Name = "aws_instance.domain_manager"
  }
}


##
## Security group for server used to administer and manage AD
##

#security group for ec2 manager to allow rdp
resource "aws_security_group" "allow_rdp" {
  name        = "Allow RDP"
  description = "Allow RDP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.example.id

  tags = {
    Name = "aws_security_group.allow_rdp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_rdp" {
  security_group_id = aws_security_group.allow_rdp.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 3389
  ip_protocol = "tcp"
  to_port     = 3389
}

resource "aws_vpc_security_group_ingress_rule" "vpc" {
  security_group_id = aws_security_group.allow_rdp.id

  cidr_ipv4   = aws_vpc.example.cidr_block
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_rdp.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}


##
## Key to enable RDP for the domain management server
##

#enable rdp into the instance with an rsa key
resource "aws_key_pair" "windows-ad-manager-server" {
  key_name   = "aws-ad-manager-server"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDk59ExsAiKy9PxFR0+hMKzXg5Z8ofFAzBUhqK1jiDMyKHYe72P0rk5FcPrNsBGWmceUdHs9Vj/rHLrjBWkY9zUQcfvk4k9i3mBf3g4llTw/8FjzcbDSqQDekgKpVcWw4A54PrcZvhmCCdRR2nQzGRHDlsfgsLawIfqRLnmQbKd+Hq6gv9iOl0mF2KZ00/TNkMUg949brTtsFnILrvXwRenzO0TcMfzLVcKDWoy5Rnqya7+zgZOF0ibwt6AVq+aFhKl/lp11DhtjZxKowQv8JsW79HhFYn43juNvMdpV2XOAvyLsMEvjerf6XhLVWulhKSNVMCaUihD3fbmEbp9S6W8maybKB1/aAKgHFdbnaCm6NQdvxS9Km4oWH26Fy0OmrZRgm9X92fPay+ovyKfIrl5IMQhgZ74uCDHZjTo5v0B8isWpnW1etspqfUFtkJBNLUM6zfX7Jusztf/27iHonEHH2ONGrhxglmmk2A56JXXgK/QQ0h1sxDUI0Mmn5Gs8zU= kylechrzanowski@Kyles-MBP.attlocal.net"
}


##
## Permissions necessary to manage AD
##

## permissions necessary to manage active directory
resource "aws_iam_instance_profile" "ec2_ad_manager_profile" {
  name = "ADController"
  role = aws_iam_role.ad_manager_role.name ###
}

resource "aws_iam_role" "ad_manager_role" {
  name               = "ADManagerRole"
  assume_role_policy = data.aws_iam_policy_document.ad_manager_role.json
  
}

data "aws_iam_policy_document" "ad_manager_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "SSMManagedInstanceCore" {
  role       = aws_iam_role.ad_manager_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "SSMDirectoryServiceAccess" {
  role       = aws_iam_role.ad_manager_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}


##
## Join the AD management server to the domain using SSM tools
##

#auth the managing server to the domain
resource "aws_ssm_document" "ad-join-domain" {
  name          = "ad-join-domain"
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "aws:domainJoin"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId" : aws_directory_service_directory.example.id,
            "directoryName" : aws_directory_service_directory.example.name
            "dnsIpAddresses" : sort(aws_directory_service_directory.example.dns_ip_addresses)
          }
        }
      ]
    }
  )
}

resource "aws_ssm_association" "windows_server" {
  name = aws_ssm_document.ad-join-domain.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.domain_manager.id]
  }
}



