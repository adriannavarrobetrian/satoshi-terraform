# Terraform AWS Web Application Infrastructure

This Terraform code deploys a web application infrastructure on AWS across three distinct environments: development, staging, and production. The infrastructure includes CloudFront distributions and separate Amazon S3 buckets for static content for each environment.

## Solution Structure

I've created 2 options for this challenge. 
Another option to separate environments would be using **terraform workspaces**, but as workspaces uses the same state file for all environments, it's not suitable for production, the blast radius is too big.


## Option 1. Flat structure with environments separated by env folder

In this solution all terraform code is in the infrastructure folder. There is a Makefile in there to apply terraform in the environment that we select.
I've used modules to create the buckets for the origin, the Cloudfront distribution and the logging buckets:

- https://github.com/terraform-aws-modules/terraform-aws-cloudfront version  = "3.2.1"

- https://github.com/terraform-aws-modules/terraform-aws-s3-bucket version  = "3.15.1"


They are hardcoded to a specific version as expected in production code. We alternately could download the modules locally and put them in a **/modules** folder or in another repository.

```
/env
    /dev
        variables.tfvars
    /staging
        variables.tfvars
    /prod
        variables.tfvars
/infrastructure
    backend.tf
    variables.tf
    dynamodb.tf
    index.html
    main.tf
    Makefile
    outputs.tf
    variables.tf
    variables.tfvars
```
Ideally the 3 environment are in separate AWS accounts.

```console
# Deploy example
# Login to the (dev|staging|prod) AWS account
make (dev|staging|prod)
# Accept changes
```

In addition to **terraform init** and **terraform plan**, the Makefile also uses **terraform fmt** to format the code, [tflint](https://github.com/terraform-linters/tflint) for linting and [tfsec](https://github.com/aquasecurity/tfsec) to check security vulnerabilities.


### Bullet points

- terraform.tfstate is configured in a S3 bucket backend named satoshi-terraform-state-${ENV} using Makefile. 
- Chicken and egg problem: I've created the bucket for the backend manually, configured it as backend, added dynamodb for state locking in terraform code and finally enabled state locking in backend configuration (in Makefile for option 1).
- All providers have versioning constraints.
- In a bigger infrastructure, main.tf could be separated in more files, in this case I think it's easier to read with only one file.
- Variables common for all environments are assigned in **infrastructure/variables.tfvar**, variables that differ per environment are assigned in **env/variables.tfvars**.
- Buckets are encrypted, private and version enabled.
- Code is self-explanatory, but I added comments to clarify some decisions.


## Option 2. Different environments in different folders

In this solution every environment is a different folder, they all access the same modules as option 1.

- https://github.com/terraform-aws-modules/terraform-aws-cloudfront version  = "3.2.1"

- https://github.com/terraform-aws-modules/terraform-aws-s3-bucket version  = "3.15.1"


They are hardcoded to a specific version as expected in production code. We alternatively could download the modules locally and put them in **/modules** folder.

```
/infrastructure
  /dev
      backend.tf
      variables.tf
      dynamodb.tf
      index.html
      main.tf
      outputs.tf
      variables.tf
      variables.tfvars
  /staging
      backend.tf
      variables.tf
      dynamodb.tf
      index.html
      main.tf
      outputs.tf
      variables.tf
      variables.tfvars
  /prod
      backend.tf
      variables.tf
      dynamodb.tf
      index.html
      main.tf
      outputs.tf
      variables.tf
      variables.tfvars
``````

```console
# Deploy example
# Login to the (dev|staging|prod) AWS account
cd ./infrastructure/${ENV}
terraform init
terraform fmt && tflint && tfsec && terraform plan -var-file=variables.tfvars 
terraform apply -var-file=variables.tfvars
# Accept changes
```

### Bullet points

- terraform.tfstate is configured in a S3 bucket backend named satoshi-terraform-state-${ENV}.
- All providers have versioning constraints.
- In a bigger infrastructure, main.tf could be separated in more files, in this case I think it's easier to read with only one file.
- Variables are for the folder specific environment.
- Buckets are encrypted, private and version enabled.
- In this option we have more code duplication than option 1. 
- On the other hand, it's probably better discernible what code is for each environment. 
- We could use Terragrunt to avoid code repetition.


## Improvements

- We can deploy the infrastructure with a pipeline in GitHub Actions.
- We could assume a AWS role in each AWS account with the necessary permissions to deploy code in every environment.


## Conclusion

This Terraform solution follows industry best practices for security, scalability, and code structure. It separates concerns into modules, adheres to the principle of least privilege in IAM permissions, and parameterizes configurations using variables and outputs.

