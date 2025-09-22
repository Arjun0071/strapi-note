output "key_pair_private_key" {
  description = "Private key to SSH into the EC2 instance"
  value       = tls_private_key.strapi_tls.private_key_pem
  sensitive   = true
}

output "ec2_public_ip" {
  description = "Public IP of the Strapi EC2 instance"
  value       = aws_instance.strapi_ec2.public_ip
}

output "strapi_url" {
  description = "URL to access Strapi"
  value       = "http://${aws_instance.strapi_ec2.public_ip}:1337/admin"
}
