################################################################################
# User pool
################################################################################

resource "aws_cognito_user_pool" "userpool" {

  tags = merge(
    { "Name" = var.userpool_name },
    var.tags,
    var.default_tags,
  )

  dynamic "account_recovery_setting" {
    for_each = var.account_recovery_setting
    content {
      recovery_mechanism {
        name     = account_recovery_setting.value.name
        priority = account_recovery_setting.value.priority
      }
    }
  }

  name = var.userpool_name

  admin_create_user_config {
    allow_admin_create_user_only = var.admin_create_user_config.allow_admin_create_user_only

    invite_message_template {
      email_message = var.admin_create_user_config.invite_message_template.email_message
      email_subject = var.admin_create_user_config.invite_message_template.email_subject
      sms_message   = var.admin_create_user_config.invite_message_template.sms_message
    }
  }

  auto_verified_attributes = var.auto_verified_attributes
  deletion_protection      = var.deletion_protection

  email_configuration {
    configuration_set      = var.email_configuration.configuration_set
    email_sending_account  = var.email_configuration.email_sending_account
    from_email_address     = var.email_configuration.from_email_address
    reply_to_email_address = var.email_configuration.reply_to_email_address
    source_arn             = var.email_configuration.source_arn
  }

  mfa_configuration = var.mfa_configuration

  dynamic "sms_configuration" {
    for_each = var.mfa_configuration == "ON" || var.mfa_configuration == "OPTIONAL" ? [1] : []
    content {
      external_id   = var.sms_configuration.external_id
      sns_caller_arn = var.sms_configuration.sns_caller_arn
    }
  }

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration == "ON" || var.mfa_configuration == "OPTIONAL" ? [1] : []
    content {
      enabled = var.software_token_mfa_configuration.enabled
    }
  }

  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    # password_history_size            = var.password_policy.password_history_size
    require_lowercase                = var.password_policy.require_lowercase
    require_numbers                  = var.password_policy.require_numbers
    require_symbols                  = var.password_policy.require_symbols
    require_uppercase                = var.password_policy.require_uppercase
    temporary_password_validity_days = var.password_policy.temporary_password_validity_days
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = var.user_attribute_update_settings.attributes_require_verification_before_update
  }

  username_configuration {
    case_sensitive = var.username_configuration.case_sensitive
  }

  verification_message_template {
    default_email_option  = var.verification_message_template.default_email_option
    email_message         = var.verification_message_template.email_message
    email_message_by_link = var.verification_message_template.email_message_by_link
    email_subject         = var.verification_message_template.email_subject
    email_subject_by_link = var.verification_message_template.email_subject_by_link
    sms_message           = var.verification_message_template.sms_message
  }


}


# Basic authentication client
resource "aws_cognito_user_pool_client" "public_client" {
  name = format("%s-public-client", var.userpool_name)

  user_pool_id                  = aws_cognito_user_pool.userpool.id
  generate_secret               = false
  refresh_token_validity        = 90
  access_token_validity = 10
  id_token_validity = 1
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  callback_urls                        = var.client_callback_urls
  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_flows          = ["code", "implicit"]
  allowed_oauth_scopes         = ["email", "openid", "phone", "profile"]
  supported_identity_providers = ["COGNITO"]

}

# Something went wrong: An error occurred (InvalidParameterException) when calling the InitiateAuth operation: USER_PASSWORD_AUTH flow not enabled for this client


# M2M authentication client
resource "aws_cognito_user_pool_client" "api_client" {
  name = format("%s-api-client", var.userpool_name)

  user_pool_id                  = aws_cognito_user_pool.userpool.id
  generate_secret               = true
  refresh_token_validity        = 90
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  callback_urls                        = ["http://localhost:4200"]
  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_flows          = ["client_credentials"]
  allowed_oauth_scopes         = [format("%s/admin", var.resource_server_identifier)]
  supported_identity_providers = ["COGNITO"]

  depends_on = [aws_cognito_resource_server.resource]


}




# Basic domain for authentication
resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = var.userpool_domain
  user_pool_id = aws_cognito_user_pool.userpool.id
}


################################################################################
# Resource servers (for client id)
################################################################################

resource "aws_cognito_resource_server" "resource" {
  identifier = var.resource_server_identifier
  name       = var.resource_server_name

  dynamic "scope" {
    for_each = var.scopes
    content {
      scope_name        = scope.value.name
      scope_description = scope.value.description
    }
  }

  user_pool_id = aws_cognito_user_pool.userpool.id

}


################################################################################
# User groups
################################################################################


resource "aws_cognito_user_group" "main" {

  for_each = var.groups

  name         = each.key
  user_pool_id = aws_cognito_user_pool.userpool.id

}
