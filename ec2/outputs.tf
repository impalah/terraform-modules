
output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}


output "public_dns_name" {
  value = aws_instance.ec2_instance.public_dns
}

# output "private_key" {
#   description = "The private key"
#   value       = tls_private_key.ec2-key-pair.private_key_pem
#   sensitive   = true
# }

# output "key_name" {
#   value = aws_key_pair.ec2-key-pair.key_name
# }
