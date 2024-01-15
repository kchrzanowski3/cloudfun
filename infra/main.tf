
#filter the ami images to result in the ubuntu image created by packer
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-packer-cloudfun-*"]
  }
}
/*
#stand up an ubuntu ec2 image created in packer to test things with
resource "aws_instance" "ubuntu-packer" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  
  subnet_id       = aws_subnet.pub_test.id  # Place the instance in the public subnet
  associate_public_ip_address = true  # Request a public IP address for the instance

  tags = {
    Name = "test ec2 linux"
  }
}*/

resource "aws_instance" "ec2tester" {
  ami           = "ami-0005e0cfe09cc9050"  # Free tier eligible AMI (check for latest)
  instance_type = "t2.micro"  # Free tier eligible instance type
  subnet_id = aws_subnet.az1-pub.id
  associate_public_ip_address = true
  
  # Necessary for free tier eligibility
  tenancy = "default"

  # Optional: Add a key pair for SSH access
  key_name = aws_key_pair.deployer.key_name  # Replace with your key pair name

  tags = {
    Name = "aws_instance.ec2tester"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-ec2-test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvnZN3OXLoIsPzWT3kcqnvF58gkLPJYfVBgHYISv72LbnvA0wsvnAraoICVEgBn2ptnA+Qik1SwQ4Us2NpUVBo5zdP5vPh3zipIKSfbxjY22TdgZ6wTPGU9Rc5MKj64GOM7ggV5ajkVuJoAuaAW4pP9/e0DAA/XRu2TBQJyHqi7aHDrQ64xXS145Pm5GdD3Eomf9NCiaPuepkeLxvIE0USfjf1lEuEw9GrVWInBgeZM10WrP+23pweI+/8AcqV3Rpt0LaTCaYvOn0pXF0L/O7nH2iBXX+JTfJahsOKkVT7w/rUIlf7tjRqZ8CywkAlxp1HyxHpKkGNi6b4/BfQY3IrRF1JUooNFeoEjK6h8bRBh/IkYzYo7/Jd9gLoMMUhlidfuZ+yTgju2cHgHsWpMy2q+bZWYc1aXeuE7Yv3q/jJemefulCNDnZdkBhnEkD7mW8OkKSzcPy+InEHloOce5GsBbCNJIxplbIlctscCGF+ofqxptQ4ySYcFay5WKTEi4M= kylechrzanowski@Kyles-MBP.attlocal.net"
}
