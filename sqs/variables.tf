variable "queue_name" {
  description = "Name of the SQS queue (without .fifo suffix)"
  type        = string
}

variable "fifo_queue" {
  description = "Indicates if the queue is FIFO"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  type    = bool
  default = false
}

variable "delay_seconds" {
  type    = number
  default = 0
}

variable "max_message_size" {
  type    = number
  default = 262144
}

variable "message_retention_seconds" {
  type    = number
  default = 345600
}

variable "receive_wait_time_seconds" {
  type    = number
  default = 0
}

variable "visibility_timeout_seconds" {
  type    = number
  default = 30
}

variable "create_dead_letter_queue" {
  type    = bool
  default = false
}

variable "max_receive_count" {
  type    = number
  default = 5
}

variable "dlq_message_retention_seconds" {
  type    = number
  default = 1209600
}

variable "project" {
  description = "Project name"
  type        = string
  default     = ""
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
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

