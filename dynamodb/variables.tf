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

variable "tags" {
  description = "External tags map"
  type        = map(string)
  default     = {}
}

variable "table_attributes" {
  description = "Map of DynamoDB attribute names and types"
  type        = list(map(string))
  default     = []
}

variable "point_in_time_recovery_enabled" {
  description = "Point in time recovery"
  type        = bool
  default     = false
}

variable "billing_mode" {
  description = "Billing mode"
  type        = string
  default     = "PROVISIONED"
}

variable "deletion_protection_enabled" {
  description = "Deletion protection enabled"
  type        = bool
  default     = false
}

variable "stream_enabled" {
  description = "Stream enabled"
  type        = bool
  default     = false
}

variable "read_capacity" {
  description = "Read capacity"
  type        = number
  default     = 1
}

variable "write_capacity" {
  description = "Write capacity"
  type        = number
  default     = 1
}

variable "table_class" {
  description = "Table class"
  type        = string
  default     = "STANDARD"
}

variable "hash_key" {
  description = "Hash key"
  type        = string
  default     = "id"
}

variable "table_name" {
  description = "Table name"
  type        = string
  default     = "celery"
}


variable "global_secondary_indexes" {
  description = "List of maps representing the global secondary indexes"
  type = list(object({
    name            = string
    hash_key        = string
    write_capacity  = number
    read_capacity   = number
    projection_type = string
  }))
  default = []
}