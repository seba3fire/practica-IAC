# ============================================================
# Outputs del proyecto — valores exportados tras el apply
# ============================================================

output "vpc_id" {
  description = "ID de la VPC principal creada"
  value       = aws_vpc.principal.id
}

output "subred_publica_id" {
  description = "ID de la subred pública"
  value       = aws_subnet.publica.id
}

output "subred_privada_id" {
  description = "ID de la subred privada (disponible para futuros recursos)"
  value       = aws_subnet.privada.id
}

output "ip_publica_instancia" {
  description = "Dirección IP pública de la instancia EC2"
  value       = aws_instance.servidor_web.public_ip
}

output "dns_publico_instancia" {
  description = "Nombre DNS público de la instancia EC2"
  value       = aws_instance.servidor_web.public_dns
}

output "comando_ssh" {
  description = "Comando listo para conectarse a la instancia por SSH"
  value       = "ssh -i <tu-clave-privada>.pem ec2-user@${aws_instance.servidor_web.public_ip}"
}

output "url_nginx" {
  description = "URL para acceder al servidor Nginx desplegado en la instancia"
  value       = "http://${aws_instance.servidor_web.public_ip}"
}
