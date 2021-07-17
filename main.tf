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

  #vpc
  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs = data.aws_availability_zones.available.names #TODO: Availability zone/s of choice can be indicated manually. 
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnets_per_vpc)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnets_per_vpc)

  enable_nat_gateway = true
  single_nat_gateway  = var.single_nat_gateway 
  one_nat_gateway_per_az = var.one_nat_gateway_per_az 
  
  #vpn
  enable_vpn_gateway = true
  # vpn_gateway_az = data.aws_availability_zones.available.names[0]
  customer_gateways = { #TODO: Add another map entry when adding another customer gateway
    default = {
      bgp_asn    = var.cgw_bgp_asn
      ip_address = var.cgw_ip
      type       = "ipsec.1" 
    }
  }
  propagate_private_route_tables_vgw = var.private_routetable_propagate_bool 
  propagate_public_route_tables_vgw = var.public_routetable_propagate_bool

}

# resource "aws_vpn_connection" "vpn-connection" {
#   customer_gateway_id = module.vpc.cgw_ids[0]
#   vpn_gateway_id      = module.vpc.vgw_id
#   type                = "ipsec.1"
# }

module "vpn_gateway" {
  source  = "terraform-aws-modules/vpn-gateway/aws"
  version = "~> 2.0"

  vpc_id                  = module.vpc.vpc_id
  vpn_gateway_id          = module.vpc.vgw_id
  customer_gateway_id     = module.vpc.cgw_ids[0]

  # precalculated length of module variable vpc_subnet_route_table_ids
  vpc_subnet_route_table_count = 2
  vpc_subnet_route_table_ids   = module.vpc.private_route_table_ids

  # tunnel inside cidr & preshared keys (optional)
  # tunnel1_inside_cidr   = var.custom_tunnel1_inside_cidr
  # tunnel2_inside_cidr   = var.custom_tunnel2_inside_cidr
  # tunnel1_preshared_key = var.custom_tunnel1_preshared_key
  # tunnel2_preshared_key = var.custom_tunnel2_preshared_key
}