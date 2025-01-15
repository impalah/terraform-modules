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

variable "access_role_policy" {
  description = "App Runner access role policy"
  type        = string
  default     = null
}

variable "instance_role_policy" {
  description = "App Runner instance role policy"
  type        = string
  default     = null
}

variable "port" {
  description = "Port where the container is exposed"
  type        = string
  default     = "8080"
}

variable "auto_deployments_enabled" {
  description = "Enable auto deployments"
  type        = bool
  default     = true
}

variable "is_publicly_accessible" {
  description = "Is the service publicly accessible"
  type        = bool
  default     = true
}

variable "cpu" {
  description = "Number of CPU units reserved for each instance of your App Runner service represented as a String. Defaults to 1024. Valid values: 256|512|1024|2048|4096|(0.25|0.5|1|2|4) vCPU."
  type        = string
  default     = "1024"

  validation {
    condition     = can(regex("^(256|512|1024|2048|4096|0.25|0.5|1|2|4)$", var.cpu))
    error_message = "The cpu variable must be one of the following values: 256, 512, 1024, 2048, 4096, 0.25, 0.5, 1, 2, 4."
  }
}

variable "memory" {
  description = "Amount of memory, in MB or GB, reserved for each instance of your App Runner service. Defaults to 2048. Valid values: 512|1024|2048|3072|4096|6144|8192|10240|12288|(0.5|1|2|3|4|6|8|10|12) GB."
  type        = string
  default     = "2048"

  validation {
    condition     = can(regex("^(512|1024|2048|3072|4096|6144|8192|10240|12288|0.5|1|2|3|4|6|8|10|12)$", var.memory))
    error_message = "The memory variable must be one of the following values: 512, 1024, 2048, 3072, 4096, 6144, 8192, 10240, 12288, 0.5, 1, 2, 3, 4, 6, 8, 10, 12."
  }
}

variable "health_check_configuration" {
  description = "Configuration for health checks"
  type = object({
    path                = string
    protocol            = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
  default = {
    path                = "/"
    protocol            = "TCP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}
