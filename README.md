# AWS VPN and VPC Automated Creation
These templates build the following AWS resources: 
- VPC
- Subnets
- Route Tables
- NAT Gateways
- Internet Gateway
- VPN Site-to-Site Connection
- Customer Gateway
- Virtual Private Gateway

## How to Use
The deployment instructions describe a default deployment setting and a custom one. Custom deployments that do not correspond to the [default architecture](#default-architecture) provided below should proceed to [Custom Settings](#custom-settings)

### Default Settings
#### Default Architecture
![alt text](https://github.com/nicamedrano-cascadeo/happy-meal-vpn-vpc-automation/blob/master/architecture-diagrams/default-architecture-white-bg.png)

#### Configuration Steps
- Clone this repository on your local machine
- Get ready with the AWS Account Credentials where the resources will be provisioned
- Execute `terraform init` to initialize terraform environment
- Execute `terraform apply` to provision the AWS Resources
    - Upon execution, you will be asked to provide the following details:
        - *var.aws_profile: AWS profile to be used to launch the AWS resources. Set to 'default' if none was set.*
            - e.g. `test`
        - *var.credentials_file: AWS credentials file location*
            - e.g. `/Users/user/.aws/credentials`
    - Verify resources to be provisioned. 
    - When asked *Do you want to perform these actions?* Type `yes` then press enter
    

### Custom Settings
#### Customizable Parameters
- AWS Configuration
    - The ff variables are used to authorize the provisioning of AWS resources using terraform:  
        - `aws_region` - AWS region where resources will be provisioned
            - default: "us-east-1"
        - `credentials_file` - Location of the AWS credentials file that contains the Access Token and Secret Access Key
        - `aws_profile` - AWS profile to be used to launch the AWS resources. Set to 'default' if none was set.
    - Sample usage:
        ```
        aws_region = "us-east-1"
        credentials_file = "/Users/user/.aws/credentials"
        aws_profile = "test"
        ```

- VPC 
    - Specify the VPC CIDR block and name to be assigned
        ```
        vpc_cidr = "10.0.0.0/16"
        vpc_name = "sample-vpc"
        ```

- Subnets
    - There are three main types of subnets supported in this template: 
        - Public Subnets: Subnets accessible through the internet. Routes to the Internet Gateway.
        - Private Subnets: Subnets that are not accessed through the internet but routes to NAT Gateways to access the internet.
        - Intra Subnets: Same as private subnets but are not connected to a NAT gateway.
    - Subnets count: Indicate how many subnets of each type should be provisioned. Default values are:
        ```
        public_subnets_per_vpc = 2
        private_subnets_per_vpc = 2
        intra_subnet_per_vpc = 0
        ```
    - Subnets CIDR: Indicate CIDR blocks to be used by the subnets. The number of CIDR blocks **should be equal or greater than** the values for the subnets count. The subnets that will be provisioned according to the subnets count indicated
        - In the example below, only 2 public, and 2 private subnets will be provisioned if `public_subnets_per_vpc` and `private_subnets_per_vpc` is equal to `2`
            ```
            public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
            private_subnet_cidr = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
            intra_subnet_cidr = []
            ```
        
    - Subnets Availability Zones: Indicate the subnets where the subnets will be provisioned
        - If none was set, the default behavior of the template is to provision the subnets in each availability zone in chronological order (starting from az-a)
        - Examples:
            - Provisions all subnets in one AZ
                ```
                subnet_azs = ["us-east-1a"]
                ```
            - Provisions public subnets in az-a and az-b, and private subnets in az-a, az-b, and az-c (Default Behavior)
                ```
                public_subnets_per_vpc = 2
                private_subnets_per_vpc = 3
                public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
                private_subnet_cidr = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
                subnet_azs = []
                ```
            - Provisions public subnets in az-a and az-b, and private subnets in az-a, az-b, and **az-a** (since there are only 2 AZs provided, the third subnet will follow the AZ from the beginning of the list, "us-east-1a")
                ```
                public_subnets_per_vpc = 2
                private_subnets_per_vpc = 3
                public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
                private_subnet_cidr = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
                subnet_azs = ["us-east-1a", "us-east-1b"]
                ```
        - Limitations:
            - It is not possible to provision the main types of subnets in the ff use case
                - private = az-a
                - public = az-b
                - intra = az-c
            - This is because these subnets follow only one availability zone variable, as bounded by the VPC module used. 
            - As a workaround, when needed, you can provision [adhoc resources](#optional-parameters) that you can customize depending on the use case and will still be able to integrate to the main vpc setup. 

- NAT Gateway
    - This template supports three scenarios for creating NAT gateways:
        - One NAT Gateway per private subnet (default behavior)
            - The number of NAT gateways will be equal to the number of Private Subnets provisioned
                ```
                enable_nat_gateway = true
                single_nat_gateway = false
                one_nat_gateway_per_az = false
                ```

        - Single NAT Gateway
            - The NAT gateway will be provisioned in the first subnet in the `public_subnets` block.
                ```
                enable_nat_gateway = true
                single_nat_gateway = true
                one_nat_gateway_per_az = false
                ```
            
        - One NAT Gateway per availability zone
            - Provisions one NAT gateway in each availability zone specified in `var.subnet_azs`. 
                - If `var.subnet_azs` is not specified, default behavior is to provision in each available AZ in chronological order (starting from a)
            - The number of public subnets must be greater than or equal to the number of availability zones specified in `var.subnet_azs`, if applicable. This is to ensure that each NAT Gateway has a dedicated public subnet to deploy to.
                ```
                enable_nat_gateway = true
                single_nat_gateway = false
                one_nat_gateway_per_az = true
                ```

    - If both `single_nat_gateway` and `one_nat_gateway_per_az` are set to **true**, then `single_nat_gateway` takes precedence.

- Route Propagation
    - Route propagation can be enabled by setting the ff variables to `true`:
        - `private_rt_propagate`
        - `public_rt_propagate`
        - `intra_rt_propagate`
    - Default settings:
        ```
        private_rt_propagate = true
        public_rt_propagate = false 
        intra_rt_propagate = false
        ```
- VPN
    - Modify the ff to create a VPN connection
        - create_vpn: Set to true to create a vpn gateway and vpn connection/s
        - vpn_gateway_az: the AZ where the Virtual Private Gateway will be provisioned. If left blank, it will follow the first az indicated in `var.subnet_azs` or in the first available subnet for the chosen region
        - customer_gateways_config: Configuration for the customer gateway. If none was set, the vpn connection will not be created. 
        - Sample usage:
            ```
            create_vpn = true
            vpn_gateway_az = ""
            customer_gateways_config = { 
                default = {
                    bgp_asn    = 65000
                    ip_address = "1.1.1.1"
                    type       = "ipsec.1" 
                }
                trial-cgw = {
                    bgp_asn    = 65000
                    ip_address = "1.1.1.2"
                    type       = "ipsec.1" 
                }
            }
            ```

#### Optional Parameters
- Tunnel Details
    - Use the following parameters to specify custom tunnel cidr and preshared keys
        ```
        custom_tunnel1_inside_cidr = ""
        custom_tunnel2_inside_cidr = ""
        custom_tunnel1_preshared_key = ""
        custom_tunnel2_preshared_key = ""
        ```

- Adhoc Resources
    - If you need to provision subnets that are outside of the scope of the main template, feel free to use the adhoc subnets and route tables. The configurations for these resources can be edited in the `main.tf` file but by default, it can provision a set of subnets in 1 AZ, and 1 route table with no routes, using the ff variables:
        ```
        adhoc_subnets_per_vpc = 1
        adhoc_subnet_cidr = ["10.0.16.0/24"]
        adhoc_rt_propagate = true
        ```
    - Refer to `main.tf` and look for **# CUSTOM RESOURCES:** to customize the adhoc resources depending on your use case (such as provisioning in a specific AZ, adding a custom route, etc)

#### Configuration Steps
- Clone this repository on your local machine
- Prepare a ***.tfvars** file with the custom values for the declared variables 
    - NOTE: See **sample.tfvars.txt** file for reference. To be able use this file in specifying the values, the .txt extension must be removed.
    - The AWS profile and Credentials file location can also be specified in the .tfvars file
- Execute `terraform init` to initialize terraform environment
- Execute `terraform apply --var-file="sample.tfvars"` to provision the AWS Resources
    - If it is not provided in the .tfvars file, upon execution, you will be asked to provide the following details:
        - *var.aws_profile: AWS profile to be used to launch the AWS resources. Set to 'default' if none was set.*
            - e.g. `test`
        - *var.credentials_file: AWS credentials file location*
            - e.g. `/Users/user/.aws/credentials`
    - Verify resources to be provisioned. 
    - When asked *Do you want to perform these actions?* Type `yes` then press enter


## References
### VPC Module
https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

### VPN Gateway Module
https://registry.terraform.io/modules/terraform-aws-modules/vpn-gateway/aws/latest

### Base Repository
https://github.com/hashicorp/learn-terraform-count-foreach
