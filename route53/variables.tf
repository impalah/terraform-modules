variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "description" {
  description = "Hosted zone description"
  type        = string
  default     = null
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

variable "tags" {
  description = "External tags map"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC for the private hosted zone"
  type        = string
  default     = null
}

variable "region" {
  description = "Region of the VPC for the private hosted zone"
  type        = string
  default     = null
}
