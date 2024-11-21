variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
  validation {
    condition     = can(regex("^us-(east|west)-[1-2]$", var.region))
    error_message = "Region must be a valid US region (e.g., us-east-1, us-west-2)."
  }
}

variable "prefix" {
  description = "Prefix to be used on all resources"
  type        = string
  default     = "demo"
  validation {
    condition     = can(regex("^[a-z0-9-]{1,16}$", var.prefix))
    error_message = "Prefix must be 1-16 characters long and may contain only lowercase letters, numbers, and hyphens."
  }
}

variable "env" {
  description = "Environment (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "prod", "demo"], var.env)
    error_message = "Environment must be one of: dev, test, prod, demo."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 28
    error_message = "VPC CIDR must be a valid IPv4 CIDR block, with a subnet mask between /16 and /28."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
  validation {
    condition     = alltrue([
      for az in var.availability_zones : 
      can(regex("^[a-z]{2}-[a-z]+-[1-2][a-c]$", az))
    ])
    error_message = "All availability zones must be valid AWS AZs in the format 'region-name-number', e.g., 'us-east-2a'. Only AZs a, b, and c are allowed."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "create_private_subnets" {
  description = "Whether to create private subnets"
  type        = bool
  default     = true
}