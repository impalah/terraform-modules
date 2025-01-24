resource "aws_acm_certificate" "cert" {
  count                     = var.domain_name != null ? 1 : 0
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "check_existing_record" {
  count = var.domain_name != null ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      aws route53 list-resource-record-sets --profile ${var.aws_profile} --hosted-zone-id ${var.zone_id} --query "ResourceRecordSets[?Name == '${element(tolist(aws_acm_certificate.cert[0].domain_validation_options), 0).resource_record_name}.'].Name" --output text > existing_record.txt
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_route53_record" "cert_validation" {
  count = var.domain_name != null && fileexists("existing_record.txt") == false ? 1 : 0

  zone_id = var.zone_id
  name    = element(tolist(aws_acm_certificate.cert[0].domain_validation_options), 0).resource_record_name
  type    = element(tolist(aws_acm_certificate.cert[0].domain_validation_options), 0).resource_record_type
  ttl     = 60
  records = [element(tolist(aws_acm_certificate.cert[0].domain_validation_options), 0).resource_record_value]

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
  }

  depends_on = [null_resource.check_existing_record]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = var.domain_name != null ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_acm_certificate" "import_cert" {
  count             = var.domain_name == null ? 1 : 0
  private_key       = var.private_key
  certificate_body  = var.certificate_body
  certificate_chain = var.certificate_chain

  lifecycle {
    create_before_destroy = true
  }
}
