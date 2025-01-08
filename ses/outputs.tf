output "verified_emails" {
  description = "List of verified email addresses"
  value       = [for email in aws_ses_email_identity.email_verifications : email.email]
}

output "verified_domain" {
  description = "Verified domain if configured"
  value       = var.use_domain ? aws_ses_domain_identity.domain[0].domain : null
}

output "dkim_tokens" {
  description = "DKIM tokens for the domain"
  value       = var.use_domain ? aws_ses_domain_dkim.dkim_tokens : []
}

output "dkim_cname_records" {
  description = "DKIM CNAME records for the domain"
  value       = var.use_domain ? [for token in aws_ses_domain_dkim.dkim_tokens : {
    name  = "${token}._domainkey.${var.domain_name}"
    value = "${token}.dkim.amazonses.com"
  }] : []
}

