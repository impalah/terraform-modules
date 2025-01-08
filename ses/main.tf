# Verify a domain for SES (if use_domain is true)
resource "aws_ses_domain_identity" "domain_identity" {
  count  = var.use_domain ? 1 : 0
  domain = var.domain_name

}

# Generate DKIM tokens for the domain (if use_domain is true)
resource "aws_ses_domain_dkim" "domain_dkim" {
  count  = var.use_domain ? 1 : 0
  domain = aws_ses_domain_identity.domain_identity[0].domain
}

# DNS records for DKIM tokens (if use_domain is true and Route 53 is used)
resource "aws_route53_record" "dkim_records" {
  count = var.use_domain ? 3 : 0

  zone_id = data.aws_route53_zone.zone[0].id
  name    = "${element(aws_ses_domain_dkim.domain_dkim[0].dkim_tokens, count.index)}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = ["${element(aws_ses_domain_dkim.domain_dkim[0].dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# Verify email addresses for SES
resource "aws_ses_email_identity" "email_verifications" {
  for_each = toset(var.email_addresses)

  email = each.value
}

# Get the Route 53 Zone ID (if use_domain is true)
data "aws_route53_zone" "zone" {
  count        = var.use_domain ? 1 : 0
  name         = var.domain_name
  private_zone = false
}
