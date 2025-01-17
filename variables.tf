# AWS CONFIGURATION
variable aws_region {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable credentials_file {
  type = string
  description = "AWS credentials file location"
}

variable aws_profile {
  type = string
  description = "AWS profile to be used to launch the AWS resources. Set to 'default' if none was set."
}

# VPC
variable vpc_cidr {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable vpc_name {
  type = string
  description = "Name of the VPC to be provisioned"
  default = "sample-vpc"
}

#SUBNETS COUNT
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

variable intra_subnets_per_vpc {
  description = "Number of private subnets. Maximum of 16."
  type        = number
  default     = 0
}

# SUBNETS CIDR
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

variable intra_subnet_cidr {
  description = "Available cidr blocks for intra subnets"
  type        = list(string)
  default = []
}

# SUBNETS AZS
variable "subnet_azs" {
  type = list(string)
  default = []
  description = "Indicate the preferred AZ where the subnets will be provisioned, if any. Set as [] if none is preferred. Default is to provision in each available AZ in chronological order"
}

# NAT GATEWAY
variable "enable_nat_gateway" {
  description = "Set to true to enable NAT gateway"
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
  description = "Set to true to provision 1 NAT gateway per AZ"
  default = false
}

# ROUTE PROPAGATION
variable "private_rt_propagate" {
  type = bool
  description = "Set to true to enable route propagation for private subnets"
  default = true
}

variable "public_rt_propagate" {
  type = bool
  description = "Set to true to enable route propagation for public subnets"
  default = false
}

variable "intra_rt_propagate" {
  type = bool
  description = "Set to true to enable route propagation for intra subnets"
  default = false
}

# VPN
variable "create_vpn" {
  type = bool
  description = "Set to true to provision VPN"
  default = true
}

variable "vpn_gateway_az" {
  type = string
  description = "Indicate the preferred AZ where the VPN gateway will be provisioned, if any. Leave blank if none."
  default = ""
}

variable "customer_gateways_config" {
  type = map(any)
  description = "The customer gateways configuration. Set to {} if none"
  default = {
    sample-cgw = { #example cgw map format
      bgp_asn    = 65000
      ip_address = "1.1.1.1"
      type       = "ipsec.1" 
    }
  }
}

# TUNNEL DETAILS (OPTIONAL: DISABLED BY DEFAULT)
variable "custom_tunnel1_inside_cidr" {
  type = string
  default = ""
}

variable "custom_tunnel2_inside_cidr" {
  type = string
  default = ""
}

variable "custom_tunnel1_preshared_key" {
  type = string
  default = ""
}

variable "custom_tunnel2_preshared_key" {
  type = string
  default = ""
}

# CUSTOM RESOURCES (OPTIONAL: DISABLED BY DEFAULT)
variable "adhoc_subnets_per_vpc" {
  type = number
  default = 0
}

variable "adhoc_subnet_cidr" {
  type = list(string)
  default = []
}

variable "adhoc_rt_propagate" {
  type = bool
  description = "Set to true to enable route propagation for adhoc subnets"
  default = false
}