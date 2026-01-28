resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "MainSubnet"
  }
}

resource "aws_instance" "ejemplo" {
  ami           = "ami-0156001f0548e90b1" # Updated to a valid Amazon Linux 2 AMI for us-east-1
  instance_type = "t3.micro"              # Changed to t3.micro (often Free Tier eligible depending on account)
  subnet_id     = aws_subnet.main.id # Associate instance with the created Subnet

  tags = {
    Name = "EjemploInstancia"
  }
}