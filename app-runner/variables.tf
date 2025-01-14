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

variable "app_name" {
  description = "Name of the App Runner service"
  type        = string
}

variable "ecr_image_uri" {
  description = "URI of the ECR image"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy App Runner"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "start_command" {
  description = "Command to start the container"
  type        = string
  default     = null
}
