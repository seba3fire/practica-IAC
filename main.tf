resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "MainSubnet"
  }
}

resource "aws_instance" "ejemplo" {
  instance_type = "t3.micro"              # Free Tier eligible instance type
  subnet_id     = aws_subnet.main.id      # Associate instance with the created Subnet
  ami           = var.ami-linux

  tags = {
    Name = "EjemploInstancia"
  }
}