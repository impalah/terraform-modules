variable "default_tags" {
  description = "A map of default tags to add to all resources"
  type        = map(string)
  default     = {
    environment   = "production"
    deployment    = "terraform"
    cost-center   = "12345"
    project       = "my-project"
    owner         = "owner-name"
    creation-date = ""
  }
}

variable "userpool_name" {
  description = "User pool name"
  type        = string
  default     = null
}

variable "account_recovery_setting" {
  description = "Account recovery setting for Cognito"
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]
}

variable "admin_create_user_config" {
  description = "Configuration for admin create user"
  type = object({
    allow_admin_create_user_only = bool
    invite_message_template = object({
      email_message = string
      email_subject = string
      sms_message   = string
    })
  })
  default = {
    allow_admin_create_user_only = true
    invite_message_template = {
      email_message = "Your username is {username} and temporary password is {####}"
      email_subject = "Welcome to our service"
      sms_message   = "Your username is {username} and temporary password is {####}"
    }
  }
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified for Cognito user pool"
  type        = list(string)
  default     = ["email"]
  validation {
    condition     = alltrue([for attr in var.auto_verified_attributes : attr == "email" || attr == "phone_number"])
    error_message = "auto_verified_attributes can only contain 'email' or 'phone_number'."
  }
}

variable "deletion_protection" {
  description = "Deletion protection setting for Cognito user pool"
  type        = string
  default     = "INACTIVE"
  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.deletion_protection)
    error_message = "deletion_protection can only be 'ACTIVE' or 'INACTIVE'."
  }
}


variable "email_configuration" {
  description = "Email configuration for Cognito user pool"
  type = object({
    configuration_set       = optional(string)
    email_sending_account   = string
    from_email_address      = optional(string)
    reply_to_email_address  = optional(string)
    source_arn              = optional(string)
  })
  default = {
    email_sending_account = "COGNITO_DEFAULT"
  }
  validation {
    condition = (
      var.email_configuration.email_sending_account == "COGNITO_DEFAULT" ||
      (var.email_configuration.email_sending_account == "DEVELOPER" && var.email_configuration.from_email_address != null && var.email_configuration.source_arn != null)
    )
    error_message = "If email_sending_account is set to DEVELOPER, from_email_address and source_arn must be set."
  }
}


variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration for the User Pool"
  type        = string
  default     = "OFF"
  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "mfa_configuration can only be 'OFF', 'ON', or 'OPTIONAL'."
  }
}

variable "sms_configuration" {
  description = "SMS configuration for MFA"
  type = object({
    external_id = optional(string)
    sns_caller_arn = string
  })
  default = null
}

variable "software_token_mfa_configuration" {
  description = "Software token MFA configuration"
  type = object({
    enabled = bool
  })
  default = null
}


variable "password_policy" {
  description = "Password policy for Cognito user pool"
  type = object({
    minimum_length                   = optional(number, 8)
    password_history_size            = optional(number, 0)
    require_lowercase                = optional(bool, true)
    require_numbers                  = optional(bool, true)
    require_symbols                  = optional(bool, true)
    require_uppercase                = optional(bool, true)
    temporary_password_validity_days = optional(number, 7)
  })
  validation {
    condition     = var.password_policy.password_history_size >= 0 && var.password_policy.password_history_size <= 24
    error_message = "password_history_size must be between 0 and 24."
  }
}


variable "user_attribute_update_settings" {
  description = "Settings for user attribute updates in Cognito user pool"
  type = object({
    attributes_require_verification_before_update = list(string)
  })
  default = {
    attributes_require_verification_before_update = ["email"]
  }
  validation {
    condition = alltrue([for attr in var.user_attribute_update_settings.attributes_require_verification_before_update : contains(var.auto_verified_attributes, attr)])
    error_message = "All attributes in attributes_require_verification_before_update must also be present in auto_verified_attributes."
  }
}

variable "username_configuration" {
  description = "Configuration for username in Cognito user pool"
  type = object({
    case_sensitive = bool
  })
  default = {
    case_sensitive = false
  }
}


variable "verification_message_template" {
  description = "Verification message template for Cognito user pool"
  type = object({
    default_email_option  = optional(string, "CONFIRM_WITH_CODE")
    email_message         = optional(string)
    email_message_by_link = optional(string)
    email_subject         = optional(string)
    email_subject_by_link = optional(string)
    sms_message           = optional(string)
  })
  validation {
    condition     = contains(["CONFIRM_WITH_CODE", "CONFIRM_WITH_LINK"], var.verification_message_template.default_email_option)
    error_message = "default_email_option must be either 'CONFIRM_WITH_CODE' or 'CONFIRM_WITH_LINK'."
  }
  validation {
    condition     = var.verification_message_template.email_message == null || contains(var.verification_message_template.email_message, "{####}")
    error_message = "email_message must contain the {####} placeholder."
  }
  validation {
    condition     = var.verification_message_template.email_message_by_link == null || contains(var.verification_message_template.email_message_by_link, "{##Click Here##}")
    error_message = "email_message_by_link must contain the {##Click Here##} placeholder."
  }
  validation {
    condition     = var.verification_message_template.sms_message == null || contains(var.verification_message_template.sms_message, "{####}")
    error_message = "sms_message must contain the {####} placeholder."
  }
}






variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


variable "userpool_public_client" {
  description = "User pool public client"
  type        = string
  default     = null
}

variable "userpool_api_client" {
  description = "User pool API client"
  type        = string
  default     = null
}

variable "userpool_domain" {
  description = "User pool domain"
  type        = string
  default     = null
}

variable "resource_server_identifier" {
  description = "Resource server identifier"
  type        = string
  default     = null
}

variable "resource_server_name" {
  description = "Resource server name"
  type        = string
  default     = null
}

variable "groups" {
  description = "Cognito groups"
  type        = set(string)
  default     = []
}

variable "client_callback_urls" {
  description = "Callback urls"
  type        = set(string)
  default     = []
}

variable "scopes" {
  description = "A list of scopes for API users"
  type = list(object({
    name        = string
    description = string
  }))
  default = [
    {
      name        = "admin"
      description = "Default scope for users"
    }
  ]
}
