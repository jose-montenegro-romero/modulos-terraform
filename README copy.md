## Terraform Commands Workflow

terraform init

terraform workspace new develop
terraform workspace new production

terraform workspace list

terraform workspace select develop
terraform workspace select production

terraform plan -var-file=./environments/env.develop.tfvars
terraform apply -var-file=./environments/env.develop.tfvars -auto-approve

terraform plan -var-file=./environments/env.production.tfvars
terraform apply -var-file=./environments/env.production.tfvars -auto-approve

terraform output -json and terraform output -raw
terraform force-unlock <ID>

ssh-keygen -m pem -b 4096 -C administrator -f nha.pem

**Destroy Infra** -> terraform destroy -var-file ./environments/env.develop.tfvars