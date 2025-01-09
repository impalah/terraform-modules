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
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "assume_role_policy" {
  description = "Lambda asume role policy"
  type        = string
  default     = null
}

variable "exec_role_policy" {
  description = "Lambda exec role policy"
  type        = string
  default     = null
}


variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = null
}


variable "function_memory" {
  description = "Function assigned memory"
  type        = string
  default     = "256"
}

variable "function_storage" {
  description = "Function assigned storage"
  type        = string
  default     = "512"
}

variable "function_timeout" {
  description = "Timeout"
  type        = string
  default     = "300"
}

variable "function_architectures" {
  description = "Architectures"
  type        = list(string)
  default     = ["x86_64"]
}

variable "image" {
  description = "ECR Image"
  type        = string
  default     = null
}

variable "logs_group_arn" {
  description = "Logs group arn"
  type        = string
  default     = null
}



variable "vpc_subnets_ids" {
  description = "RDS subnets"
  type        = set(string)
  default     = []
}

variable "vpc_id" {
  description = "ID of the VPC for the function"
  type        = string
  default     = null
}

variable "region" {
  description = "Set the primary region"
  type        = string
  default     = "us-east-1"
}

variable "env_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default = {
  }
}


variable "ports" {
  description = "A list of ingress open ports"
  type        = list(string)
  default     = []
}

variable "function_cmd" {
  description = "CMD override"
  type        = string
  default     = ""
}

variable "image_config" {
  description = "Configuration block for image configuration of the Lambda function"
  type = object({
    command = optional(list(string))
    entry_point = optional(list(string))
    working_directory = optional(string)
  })
  default = {}
}