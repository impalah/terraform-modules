
variable "instance_name" {
  description = "Instance name"
  type        = string
  default     = "bastion"
}

variable "instance_ami" {
  description = "Instance ami (varies with region)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_name" {
  description = "Key name to connect with EC2"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC for the bastion"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID of the subnet for the bastion"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


variable "az" {
  description = "Availability zone"
  type        = string
  default     = null
}


variable "instance_ingress" {
  description = "List of maps of ingress rules"
  type = list(object({
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    }
  ]
}

variable "user_data" {
  description = "Initial user data to use for the instance"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Key pair name to use for the instance"
  type        = string
  default     = null
}
