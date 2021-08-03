# configure AWS credentials
aws configure --profile=profile-name

# navigate to the directory with the VPC-VPN terraform templates
cd ~/VPN-VPC-Happy-Meal

# initialize
terraform init

# apply resources
terraform apply -var-file="test.tfvars"

# delete resources
terraform destroy

# delete resource state
terraform state rm "module.vpc"