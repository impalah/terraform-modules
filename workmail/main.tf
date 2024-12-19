resource "aws_workmail_organization" "this" {
  alias                  = var.organization_alias
  kms_key_arn            = var.use_default_kms ? null : var.custom_kms_key_arn
  enable_interoperability = true

  tags = var.tags

}

resource "aws_workmail_domain" "this" {
  count = var.domain_type == "route53" || var.domain_type == "external" ? 1 : 0

  organization_id = aws_workmail_organization.this.id
  domain          = var.domain_name

  tags = var.tags

}

resource "aws_route53_record" "mx" {
  count = var.domain_type == "route53" ? 1 : 0

  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 300
  records = ["10 inbound-smtp.${var.aws_region}.amazonaws.com"]

  tags = var.tags

}

resource "aws_workmail_user" "this" {
  for_each = { for user in var.users : user.name => user }

  organization_id = aws_workmail_organization.this.id
  name            = each.value.name
  display_name    = each.value.display_name
  password        = each.value.password

  tags = var.tags

}

resource "aws_workmail_user_alias" "this" {
  for_each = { for user in var.users : user.name => user if length(user.aliases) > 0 }

  organization_id = aws_workmail_organization.this.id
  user_id         = aws_workmail_user.this[each.key].id
  alias           = each.value.aliases[0] # Assign the first alias for simplicity

  tags = var.tags

}

