
resource "aws_ses_account" "account" {
  sandbox_enabled = var.enable_sandbox
}

resource "aws_ses_domain_identity" "domain" {
  count = var.use_domain ? 1 : 0
  domain = var.domain_name

  tags = merge(
    var.tags,
    var.default_tags,
  )

}

resource "aws_ses_domain_dkim" "dkim" {
  count = var.use_domain ? 1 : 0
  domain = aws_ses_domain_identity.domain[0].id

  depends_on = [aws_ses_domain_identity.domain]
}

resource "aws_route53_record" "domain_verification" {
  count = var.use_domain ? length(keys(aws_ses_domain_identity.domain[0].verification_attributes)) : 0

  zone_id = data.aws_route53_zone.zone.id
  name    = element(keys(aws_ses_domain_identity.domain[0].verification_attributes), count.index)
  type    = aws_ses_domain_identity.domain[0].verification_attributes[element(keys(aws_ses_domain_identity.domain[0].verification_attributes), count.index)].type
  ttl     = 300
  records = [aws_ses_domain_identity.domain[0].verification_attributes[element(keys(aws_ses_domain_identity.domain[0].verification_attributes), count.index)].value]
}

resource "aws_ses_domain_identity_verification" "verify_domain" {
  count = var.use_domain ? 1 : 0
  domain = aws_ses_domain_identity.domain[0].id

  depends_on = [aws_route53_record.domain_verification]
}

resource "aws_route53_record" "dkim_records" {
  count = var.use_domain ? length(aws_ses_domain_dkim.dkim_tokens) : 0

  zone_id = data.aws_route53_zone.zone.id
  name    = "${element(aws_ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = ["${element(aws_ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_email_identity" "email_verifications" {
  for_each = toset(var.email_addresses)

  email = each.value
}

data "aws_route53_zone" "zone" {
  count        = var.use_domain ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

