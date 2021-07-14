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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnets_per_vpc)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnets_per_vpc)

  enable_nat_gateway = true
  enable_vpn_gateway = true

  private_subnet_suffix = "private-subnet"

  propagate_private_route_tables_vgw = true 
  propagate_public_route_tables_vgw = true

  customer_gateways = {
    default = {
      bgp_asn    = 65000
      ip_address = "172.83.124.10"
      type       = "ipsec.1"
    }
  }

}

resource "aws_vpn_connection" "example" {
  customer_gateway_id = module.vpc.cgw_ids[0]
  vpn_gateway_id      = module.vpc.vgw_id
  type                = "ipsec.1"
}

# module "app_security_group" {
#   source  = "terraform-aws-modules/security-group/aws//modules/web"
#   version = "3.17.0"

#   name        = "web-server-sg-${var.project_name}-${var.environment}"
#   description = "Security group for web-servers with HTTP ports open within VPC"
#   vpc_id      = module.vpc.vpc_id

#   ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
# }
