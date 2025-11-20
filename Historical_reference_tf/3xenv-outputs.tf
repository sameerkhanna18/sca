output "private_key_pem" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "dev_public_ip" {
  value = aws_instance.dev.public_ip
}

output "qa_public_ip" {
  value = aws_instance.qa.public_ip
}

output "prod_public_ip" {
  value = aws_instance.prod.public_ip
}
