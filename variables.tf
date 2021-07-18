variable aws_region {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable credentials_file {
  type = string
  default = "/Users/cascadeoPS/.aws/creds"
}

variable aws_profile {
  type = string
  default = "test"
}

# tags
variable project_name {
  description = "Name of the project. Used in resource names and tags."
  type        = string
  default     = "happy-meal-vpn-vpc"
}

variable environment {
  description = "Value of the 'Environment' tag."
  type        = string
  default     = "dev"
}

# vpc init
variable vpc_cidr {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable vpc_name {
  type = string
  default = "sample-vpc"
}

variable public_subnets_per_vpc {
  description = "Number of public subnets. Maximum of 16."
  type        = number
  default     = 2
}

variable private_subnets_per_vpc {
  description = "Number of private subnets. Maximum of 16."
  type        = number
  default     = 2
}


variable public_subnet_cidr {
  description = "Available cidr blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
    "10.0.9.0/24",
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
    "10.0.14.0/24",
    "10.0.15.0/24",
    "10.0.16.0/24"
  ]
}

variable private_subnet_cidr {
  description = "Available cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
    "10.0.109.0/24",
    "10.0.110.0/24",
    "10.0.111.0/24",
    "10.0.112.0/24",
    "10.0.113.0/24",
    "10.0.114.0/24",
    "10.0.115.0/24",
    "10.0.116.0/24"
  ]
}

variable "subnet_azs" {
  type = list(string)
  default = null
  description = "Indicate the preferred AZ where the subnets will be provisioned, if any. Format is a list of strings. Set as null if none."
}

# NAT Gateway
variable "enable_nat_gateway" {
  type = bool
  default = true
}

variable "single_nat_gateway" {
  type = bool
  description = "Set to true if all private subnets will be routed to only 1 NAT gateway. It will be placed in the first public subnet in the public_subnets block."
  default = false
}

variable "one_nat_gateway_per_az" {
  type = bool
  description = ""
  default = false
}

# Route table propagation
variable "private_rt_propagate" {
  type = bool
  default = true
}

variable "public_rt_propagate" {
  type = bool
  default = false
}

# vpn config
variable "create_vpn" {
  type = bool
  default = true
}

variable "vpn_gateway_az" {
  type = string
  description = "Indicate the preferred AZ where the VPN gateway will be provisioned, if any. Set as null if none."
  default = null
}

variable "customer_gateways_config" {
  type = map(any)
  default = {}
}