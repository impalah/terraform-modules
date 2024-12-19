variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "organization_alias" {
  description = "Alias for the WorkMail organization"
  type        = string
}

variable "domain_type" {
  description = "Type of domain: 'route53', 'external', or 'free'"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the organization"
  type        = string
  default     = null
}

variable "use_default_kms" {
  description = "Whether to use the default KMS key"
  type        = bool
}

variable "custom_kms_key_arn" {
  description = "Custom KMS Key ARN to use if not using the default KMS"
  type        = string
  default     = null
}

variable "users" {
  description = "List of users with their display names, passwords, and aliases"
  type = list(object({
    name         = string
    display_name = string
    password     = string
    aliases      = list(string)
  }))
}
