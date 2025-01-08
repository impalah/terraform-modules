# Outputs
output "verified_emails" {
  description = "List of verified email addresses"
  value       = [for email in aws_ses_email_identity.email_verifications : email.email]
}

output "dkim_tokens" {
  description = "DKIM tokens for the domain"
  value       = var.use_domain ? aws_ses_domain_dkim.domain_dkim[0].dkim_tokens : []
}

output "dkim_cname_records" {
  description = "DKIM CNAME records for Route 53"
  value       = var.use_domain ? [for i in range(3) : {
    name  = "${aws_ses_domain_dkim.domain_dkim[0].dkim_tokens[i]}._domainkey.${var.domain_name}"
    value = "${aws_ses_domain_dkim.domain_dkim[0].dkim_tokens[i]}.dkim.amazonses.com"
  }] : []
}