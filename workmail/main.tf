resource "null_resource" "create_workmail_organization" {
  provisioner "local-exec" {
    command = <<EOT
      aws workmail create-organization \
        --alias ${var.organization_alias} \
        --region ${var.region} \
        --query 'OrganizationId' --output text > organization_id.txt
    EOT
  }
}

resource "null_resource" "associate_domain" {
  depends_on = [null_resource.create_workmail_organization]

  provisioner "local-exec" {
    command = <<EOT
      aws workmail register-to-workmail \
        --organization-id $(cat organization_id.txt) \
        --domain ${var.domain_name} \
        --region ${var.region}
    EOT
  }
}

resource "null_resource" "create_workmail_users" {
  count = length(var.users)

  provisioner "local-exec" {
    command = <<EOT
      aws workmail create-user \
        --organization-id $(cat organization_id.txt) \
        --name "${element(var.users, count.index).name}" \
        --display-name "${element(var.users, count.index).display_name}" \
        --password "${element(var.users, count.index).password}" \
        --region ${var.region}
    EOT
  }
}

resource "null_resource" "create_workmail_alias" {
  count = length(var.users)

  provisioner "local-exec" {
    command = <<EOT
      aws workmail create-alias \
        --organization-id $(cat organization_id.txt) \
        --entity-id "$(aws workmail list-users --organization-id $(cat organization_id.txt) --query 'Users[?Name==`${element(var.users, count.index).name}`].Id' --output text)" \
        --alias "${element(var.users, count.index).aliases[0]}" \
        --region ${var.region}
    EOT
  }
}


