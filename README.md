# Automate A simple hello-world springboot application in AWS cloud

Follow below steps to Deploy this application:

1. Download and Install Terraform software. Ignore if terraform binary already available. 
   a. Link: https://www.terraform.io/downloads.html
2. Clone this Repo to your desktop
   `git clone https://github.com/rkondakindi/my-app/`
3. Change directory to `terraform/myapp-infra`
   `cd terraform/myapp-infra`
4. Create `terraform.tfvars` file as mentioned in https://github.com/rkondakindi/my-app/terraform/myapp-infra/README.md
5. Run Terraform
   ```
   terraform init
   terraform plan
   terraform apply
   ```
6. Successful Terraform deploy display outputs and click on `url_name` value to access page.
