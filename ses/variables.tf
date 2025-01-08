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

variable "enable_sandbox" {
  description = "Whether to keep SES in sandbox mode or request production access"
  type        = bool
  default     = true
}

variable "use_domain" {
  description = "Whether to configure SES with a domain or not"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain to verify with SES (if use_domain is true)"
  type        = string
  default     = ""
}

variable "email_addresses" {
  description = "List of email addresses to verify with SES"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
