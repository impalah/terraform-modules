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

variable "domain_name" {
  type        = string
  default     = null
  description = "Domain name for the hosted zone."
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "A list of domains that should be SANs in the issued certificate."
}

variable "zone_id" {
  type        = string
  default     = null
  description = "The ID of the hosted zone to contain this record."
}

variable "private_key" {
  type        = string
  default     = null
  description = "Private key."
}

variable "certificate_body" {
  type        = string
  default     = null
  description = "Certificate body."
}

variable "certificate_chain" {
  type        = string
  default     = null
  description = "Certificate chain."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "default_tags" {
  description = "A map of default tags to add to all resources"
  type        = map(string)
  default = {
    environment   = "production"
    deployment    = "terraform"
    cost-center   = "12345"
    project       = "my-project"
    owner         = "owner-name"
    creation-date = ""
  }
}

