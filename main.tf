terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.credentials_file
  profile                 = var.aws_profile
}

data "aws_availability_zones" "available" {
  state = "available"
}

######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.tags,
    var.vpc_tags,
  )
}

# resource "aws_vpn_connection" "vpn-connection" {
#   count = var.create_vpn ? length(var.customer_gateways_config): 0 
#   customer_gateway_id = module.vpc.cgw_ids != null ? module.vpc.cgw_ids[count.index]: null
#   vpn_gateway_id      = module.vpc.vgw_id
#   type                = "ipsec.1"
# }