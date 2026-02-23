# Portafolio Terraform AWS — Infraestructura como Código

Proyecto de **Infraestructura como Código (IaC)** usando **Terraform** sobre **AWS**, desarrollado como parte de mi portafolio profesional. Demuestra el aprovisionamiento automatizado de una arquitectura de red completa con una instancia web.

## Arquitectura

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
VPC (10.0.0.0/16)
 ├── Subred Pública (10.0.1.0/24) — us-east-1a
 │       └── EC2 t3.micro (Nginx) ◄── Security Group (SSH:22 / HTTP:80)
 └── Subred Privada (10.0.2.0/24) — us-east-1b
         └── (disponible para RDS, backends, etc.)
```

## Recursos aprovisionados

| Recurso | Descripción |
|---|---|
| `aws_vpc` | Red privada virtual con soporte DNS |
| `aws_subnet` (x2) | Subred pública y subred privada en distintas AZs |
| `aws_internet_gateway` | Acceso a Internet para la subred pública |
| `aws_route_table` | Tabla de rutas con ruta por defecto al IGW |
| `aws_security_group` | Permite tráfico HTTP (80) y SSH (22) de entrada |
| `aws_key_pair` | Clave SSH para acceso seguro a la instancia |
| `aws_instance` | EC2 t3.micro con Amazon Linux 2 y Nginx instalado automáticamente |

## Tecnologías

- [Terraform](https://www.terraform.io/) `>= 1.6.0`
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) `~> 5.0`
- Amazon Web Services (VPC, EC2, IAM)

## Requisitos previos

1. [Terraform CLI](https://developer.hashicorp.com/terraform/install) instalado (`>= 1.6.0`)
2. [AWS CLI](https://aws.amazon.com/cli/) configurado con credenciales válidas (`aws configure`)
3. Un par de claves SSH generado localmente:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/practica-iac
   ```

## Variables configurables

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `region` | Región de AWS | `us-east-1` |
| `nombre_proyecto` | Prefijo usado en el nombre de los recursos | `practica-iac` |
| `entorno` | Entorno (`desarrollo`, `staging`, `produccion`) | `desarrollo` |
| `tipo_instancia` | Tipo de EC2 (solo free-tier: `t2.micro`, `t3.micro`) | `t3.micro` |
| `clave_ssh_publica` | Contenido de tu clave pública SSH (`.pub`) | *(requerida)* |
| `cidr_vpc` | CIDR de la VPC | `10.0.0.0/16` |
| `cidr_subred_publica` | CIDR de la subred pública | `10.0.1.0/24` |
| `cidr_subred_privada` | CIDR de la subred privada | `10.0.2.0/24` |

## Uso

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd practica-IAC

# 2. Inicializar Terraform (descarga el proveedor AWS)
terraform init

# 3. Revisar el plan de ejecución
terraform plan -var="clave_ssh_publica=$(cat ~/.ssh/practica-iac.pub)"

# 4. Aplicar los cambios (crea la infraestructura en AWS)
terraform apply -var="clave_ssh_publica=$(cat ~/.ssh/practica-iac.pub)"

# 5. Destruir la infraestructura cuando ya no se necesite
terraform destroy -var="clave_ssh_publica=$(cat ~/.ssh/practica-iac.pub)"
```

## Outputs

Tras ejecutar `terraform apply`, se muestran los siguientes valores:

| Output | Descripción |
|---|---|
| `vpc_id` | ID de la VPC creada |
| `subred_publica_id` | ID de la subred pública |
| `subred_privada_id` | ID de la subred privada |
| `ip_publica_instancia` | IP pública de la instancia EC2 |
| `dns_publico_instancia` | DNS público de la instancia |
| `url_nginx` | URL del servidor web Nginx |
| `comando_ssh` | Comando SSH listo para conectarse |

## Notas

> ⚠️ **Costos:** Si bien la instancia `t3.micro` está dentro del nivel gratuito de AWS (Free Tier), asegurate de destruir los recursos con `terraform destroy` cuando no los necesités para evitar cargos inesperados.

> 🔒 **Seguridad:** El Security Group expone el puerto 22 (SSH) a `0.0.0.0/0` para facilitar el acceso en entornos de práctica. En producción, limitarlo a una IP específica.