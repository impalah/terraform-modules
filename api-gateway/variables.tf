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

variable "api_type" {
  description = "API type. Valid values: HTTP, REST."
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "REST"], var.api_type)
    error_message = "api_type must be either 'HTTP' or 'REST'."
  }
}

variable "api_name" {
  description = "Api name"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC to create a VPC endpoint in"
  type        = string
  default     = null
}

variable "vpc_subnets_ids" {
  description = "RDS subnets"
  type        = set(string)
  default     = []
}

variable "protocol_type" {
  description = "API protocol. Valid values: HTTP, WEBSOCKET."
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "WEBSOCKET"], var.protocol_type)
    error_message = "protocol_type must be either 'HTTP' or 'WEBSOCKET'."
  }
}

variable "integration_type" {
  description = "Integration type. Valid values: HTTP_PROXY, AWS_PROXY, MOCK."
  type        = string
  default     = "HTTP_PROXY"
  validation {
    condition     = contains(["HTTP_PROXY", "AWS_PROXY", "MOCK"], var.integration_type)
    error_message = "integration_type must be either 'HTTP_PROXY', 'AWS_PROXY' or 'MOCK'."
  }
}

variable "integration_uri" {
  description = "The URI of the service that the API Gateway calls to execute the integration."
  type        = string
  default     = null
}

variable "payload_format_version" {
  description = "The version of the payload format. Valid values: 1.0, 2.0."
  type        = string
  default     = "1.0"
  validation {
    condition     = contains(["1.0", "2.0"], var.payload_format_version)
    error_message = "payload_format_version must be either '1.0' or '2.0'."
  }
}

variable "integration_method" {
  description = "The integration's HTTP method. When the integration_type is HTTP_PROXY, this field is required."
  type        = string
  default     = "ANY"
}

variable "timeout_milliseconds" {
  description = "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
  type        = number
  default     = 29000
  validation {
    condition     = var.timeout_milliseconds >= 50 && var.timeout_milliseconds <= 29000
    error_message = "timeout_milliseconds must be between 50 and 29,000 milliseconds."
  }
}

variable "route_method" {
  description = "The route method for the route"
  type        = string
  default     = "ANY"
}

variable "route_path" {
  description = "The route path for the route"
  type        = string
  default     = "/{proxy+}"
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = null
}

variable "stage_name" {
  description = "Name for the stage"
  type        = string
  default     = null
}


