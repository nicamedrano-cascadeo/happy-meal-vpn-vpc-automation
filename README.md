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
