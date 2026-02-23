# ============================================================
# Variables de configuración del proyecto
# ============================================================

variable "region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "nombre_proyecto" {
  description = "Nombre del proyecto, usado en los tags de los recursos"
  type        = string
  default     = "portafolio-terraform-aws"
}

variable "entorno" {
  description = "Entorno de despliegue (desarrollo, staging o produccion)"
  type        = string
  default     = "desarrollo"

  validation {
    condition     = contains(["desarrollo", "staging", "produccion"], var.entorno)
    error_message = "El entorno debe ser uno de: desarrollo, staging, produccion."
  }
}

variable "tipo_instancia" {
  description = "Tipo de instancia EC2 a utilizar (debe pertenecer al nivel gratuito de AWS)"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.tipo_instancia)
    error_message = "Solo se permiten instancias del nivel gratuito: t2.micro o t3.micro."
  }
}

variable "clave_ssh_publica" {
  description = "Clave pública SSH para acceder a la instancia EC2 (contenido del archivo .pub)"
  type        = string
  sensitive   = true
}

variable "cidr_vpc" {
  description = "Bloque CIDR de la VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cidr_subred_publica" {
  description = "Bloque CIDR de la subred pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "cidr_subred_privada" {
  description = "Bloque CIDR de la subred privada"
  type        = string
  default     = "10.0.2.0/24"
}
