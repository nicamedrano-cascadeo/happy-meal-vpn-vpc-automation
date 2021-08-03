# VPN and VPC Automated Creation
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
### Default Settings
1. Clone this repository to your local machine
2. Get ready with the AWS Account Credentials where the resources will be provisioned
3. Execute `terraform init`
4. terraform apply
5. Verify resources to be provisioned. Type yes then enter


### Custom Settings
1. Clone this repository to your local machine
2. Get ready with the AWS Account Credentials where the resources will be provisioned
3. Create a *.tfvars file to indicate specific values for the variables
4. Execute terraform init
5. terraform apply -var-file="test.tfvars"