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
  cidr = var.vpc_cidr

  azs = var.subnet_azs != [] ? var.subnet_azs : data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr, 0, var.private_subnets_per_vpc)
  public_subnets  = slice(var.public_subnet_cidr, 0, var.public_subnets_per_vpc)

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway  = var.enable_nat_gateway ? var.single_nat_gateway : false
  one_nat_gateway_per_az = var.enable_nat_gateway? var.one_nat_gateway_per_az : false
  
  #vpn
  enable_vpn_gateway = var.create_vpn
  vpn_gateway_az = var.create_vpn && var.vpn_gateway_az != "" ? var.vpn_gateway_az : data.aws_availability_zones.available.names[0] 
  customer_gateways = var.create_vpn ? var.customer_gateways_config : {}

  propagate_private_route_tables_vgw = var.create_vpn ? var.private_rt_propagate : false
  propagate_public_route_tables_vgw = var.create_vpn ? var.public_rt_propagate : false

}

resource "aws_vpn_connection" "vpn-connection" {
  count = var.create_vpn ? length(var.customer_gateways_config): 0 
  customer_gateway_id = module.vpc.cgw_ids != null ? module.vpc.cgw_ids[count.index]: null
  vpn_gateway_id      = module.vpc.vgw_id
  type                = "ipsec.1"
}