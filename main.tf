# ============================================================
# Red principal: VPC, subredes, gateway y rutas
# ============================================================

# VPC principal del proyecto
resource "aws_vpc" "principal" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.nombre_proyecto}-vpc"
  }
}

# Internet Gateway para dar acceso a Internet a la subred pública
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "${var.nombre_proyecto}-igw"
  }
}

# Tabla de rutas para la subred pública (ruta por defecto hacia Internet)
resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.nombre_proyecto}-rt-publica"
  }
}

# Subred pública: instancias con IP pública y acceso directo a Internet
resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.cidr_subred_publica
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "${var.nombre_proyecto}-subred-publica"
    Tipo = "publica"
  }
}

# Subred privada: sin acceso directo a Internet (para bases de datos, backends, etc.)
resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.principal.id
  cidr_block        = var.cidr_subred_privada
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.nombre_proyecto}-subred-privada"
    Tipo = "privada"
  }
}

# Asociación de la subred pública con su tabla de rutas
resource "aws_route_table_association" "asociacion_publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}

# ============================================================
# Seguridad: Security Group para la instancia web
# ============================================================

resource "aws_security_group" "web" {
  name        = "${var.nombre_proyecto}-sg-web"
  description = "Permite trafico HTTP (80) y SSH (22) de entrada; todo el trafico de salida"
  vpc_id      = aws_vpc.principal.id

  # Regla de entrada: SSH (solo para administración)
  ingress {
    description = "SSH desde cualquier origen"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de entrada: HTTP para servir la web
  ingress {
    description = "HTTP desde cualquier origen"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de salida: todo el tráfico permitido
  egress {
    description = "Todo el trafico de salida permitido"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.nombre_proyecto}-sg-web"
  }
}

# ============================================================
# Cómputo: Key Pair e instancia EC2
# ============================================================

# Clave SSH para acceder a la instancia de forma segura
resource "aws_key_pair" "clave_acceso" {
  key_name   = "${var.nombre_proyecto}-clave-ssh"
  public_key = var.clave_ssh_publica

  tags = {
    Name = "${var.nombre_proyecto}-clave-ssh"
  }
}

# Data source: obtiene la AMI más reciente de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Script de inicio: instala y arranca Nginx automáticamente al lanzar la instancia
locals {
  user_data_nginx = <<-EOF
    #!/bin/bash
    set -e
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Proyecto IaC - Terraform + AWS</h1><p>Instancia: $(hostname)</p>" > /usr/share/nginx/html/index.html
  EOF
}

# Instancia EC2 en la subred pública con Nginx instalado via user_data
resource "aws_instance" "servidor_web" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.tipo_instancia
  subnet_id              = aws_subnet.publica.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.clave_acceso.key_name
  user_data              = local.user_data_nginx

  # Volumen raíz de 8 GB con cifrado habilitado
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.nombre_proyecto}-servidor-web"
  }
}
