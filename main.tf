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

  #VPC
  name = var.vpc_name
  cidr = var.vpc_cidr

  #SUBNETS
  azs = length(var.subnet_azs) != 0 ? var.subnet_azs : data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr, 0, var.private_subnets_per_vpc)
  public_subnets  = slice(var.public_subnet_cidr, 0, var.public_subnets_per_vpc)
  intra_subnets = slice(var.intra_subnet_cidr, 0, var.intra_subnets_per_vpc)

  #NAT GATEWAY
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway  = var.enable_nat_gateway ? var.single_nat_gateway : false
  one_nat_gateway_per_az = var.enable_nat_gateway? var.one_nat_gateway_per_az : false
  
  #VPN
  enable_vpn_gateway = var.create_vpn
  vpn_gateway_az = var.create_vpn && var.vpn_gateway_az != "" ? var.vpn_gateway_az : data.aws_availability_zones.available.names[0] 
  customer_gateways = var.create_vpn ? var.customer_gateways_config : {}

  #ROUTE PROPAGATION
  propagate_private_route_tables_vgw = var.create_vpn ? var.private_rt_propagate : false
  propagate_public_route_tables_vgw = var.create_vpn ? var.public_rt_propagate : false
  propagate_intra_route_tables_vgw = var.create_vpn ? var.intra_rt_propagate : false
}

# VPN
module "vpn_gateway" {
  source  = "terraform-aws-modules/vpn-gateway/aws"
  version = "~> 2.0"
  count = var.create_vpn ? length(var.customer_gateways_config): 0 

  vpc_id                  = module.vpc.vpc_id
  vpn_gateway_id          = module.vpc.vgw_id
  customer_gateway_id     = length(module.vpc.cgw_ids) != 0 ? module.vpc.cgw_ids[count.index]: null

  # TUNNEL INSIDE CUSTOM CIDR AND PRESHARED KEYS (OPTIONAL: DISABLED BY DEFAULT)
  tunnel1_inside_cidr   = var.custom_tunnel1_inside_cidr
  tunnel2_inside_cidr   = var.custom_tunnel2_inside_cidr
  tunnel1_preshared_key = var.custom_tunnel1_preshared_key
  tunnel2_preshared_key = var.custom_tunnel2_preshared_key

  # ENABLE ROUTE PROPAGATION FOR CUSTOM RESOURCES (OPTIONAL: DISABLED BY DEFAULT) - FEEL FREE TO CUSTOMIZE BASED ON THE REQUIREMENTS
  vpc_subnet_route_table_count = var.adhoc_rt_propagate && var.adhoc_subnets_per_vpc != 0 ? 1 : 0
  vpc_subnet_route_table_ids   = var.adhoc_rt_propagate && var.adhoc_subnets_per_vpc != 0 ? [aws_route_table.adhoc[0].id] : []
}

# CUSTOM RESOURCES: USE TO MANUALLY ADD ADDITIONAL SUBNETS AND ROUTE TABLES IF NEEDED (OPTIONAL: DISABLED BY DEFAULT) - FEEL FREE TO CUSTOMIZE BASED ON THE REQUIREMENTS
resource "aws_subnet" "adhoc" {
  count = var.adhoc_subnets_per_vpc
  vpc_id     = module.vpc.vpc_id
  # availability_zone = element(data.aws_availability_zones.available.names,count.index)
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = var.adhoc_subnet_cidr[count.index]

  tags = {
    Name = "${var.vpc_name}-adhoc-subnet"
  }
}

resource "aws_route_table" "adhoc" {
  count = var.adhoc_subnets_per_vpc != 0 ? 1 : 0
  vpc_id = module.vpc.vpc_id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = module.vpc.igw_id
  # }

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = module.vpc.natgw_ids[0]
  # }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = module.vpc.egress_only_internet_gateway_id
  # }

  tags = {
    Name = "${var.vpc_name}-adhoc-route-table"
  }
}

resource "aws_route_table_association" "adhoc" {
  count = var.adhoc_subnets_per_vpc
  subnet_id      = aws_subnet.adhoc[count.index].id
  route_table_id = aws_route_table.adhoc[0].id
}