output "organization_id" {
  value = aws_workmail_organization.this.id
}

output "web_url" {
  value = "https://${aws_workmail_organization.this.alias}.awsapps.com/mail"
}
