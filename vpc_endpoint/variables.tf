variable "vpc_id" {
  description = "ID of the VPC where the endpoints will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for interface endpoints"
  type        = list(string)
  default     = []
}

variable "endpoints" {
  description = "List of VPC endpoints to create"
  type = list(object({
    name          = string                # Name of the endpoint
    service_name  = string                # AWS service name (e.g., com.amazonaws.<region>.s3)
    type          = string                # Type of the endpoint: 'Gateway' or 'Interface'
    private_dns   = optional(bool, true)  # Enable private DNS for interface endpoints
    security_groups = optional(list(string), []) # Security group IDs for interface endpoints
    policy        = optional(string, null) # Custom policy JSON for the endpoint
    route_table_ids = optional(list(string), []) # Route table IDs for gateway endpoints
  }))
  default = []
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

