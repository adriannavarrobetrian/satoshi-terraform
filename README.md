# Terraform AWS Web Application Infrastructure

This Terraform code deploys a web application infrastructure on AWS across three distinct environments: development, staging, and production. The infrastructure includes CloudFront distributions and separate Amazon S3 buckets for static content for each environment.

## Solution Structure

I've created 2 versions for this challenge.

## Version 1. Flat structure with environments separated by env folder.

In this solution all terraform code is in the infrastructure folder. There is a Makefile in there to apply terraform in the environment that we select.
I use the modules:

https://github.com/terraform-aws-modules/terraform-aws-cloudfront version  = "3.2.1"

https://github.com/terraform-aws-modules/terraform-aws-s3-bucket version  = "3.15.1"

to create the buckets for the origin, the distribution and the logging buckets.

They are hardcoded a specific version as expected in production code.

We could download the modules locally and put them in /modules folder too.




The solution is organized into modules, making it modular, maintainable, and reusable. The project structure is as follows:


```
/env
    /dev
/env
    /staging
/env 
    /prod
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


```bash
# Example installation steps
git clone https://github.com/your-username/your-project.git
cd your-project
npm install
```

This module defines the S3 bucket configurations for the web application. It includes separate buckets for each environment (dev, staging, prod). The buckets adhere to versioning and server-side encryption standards.

modules/cloudfront
This module configures CloudFront distributions for the web application. Each distribution is directed towards its respective S3 bucket and configured for the appropriate paths.

modules/iam
This module defines customized IAM policies and roles for S3 bucket and CloudFront distribution access. It upholds the principle of least privilege while designing IAM roles.

Usage

main.tf
The main Terraform configuration file references the modules and sets up the environments.

hcl
Copy code
module "s3_dev" {
  source = "./modules/s3"
  environment = "dev"
}

module "s3_staging" {
  source = "./modules/s3"
  environment = "staging"
}

module "s3_prod" {
  source = "./modules/s3"
  environment = "prod"
}

module "cloudfront_dev" {
  source = "./modules/cloudfront"
  environment = "dev"
  s3_bucket_domain_name = module.s3_dev.s3_bucket_domain_name
}

module "cloudfront_staging" {
  source = "./modules/cloudfront"
  environment = "staging"
  s3_bucket_domain_name = module.s3_staging.s3_bucket_domain_name
}

module "cloudfront_prod" {
  source = "./modules/cloudfront"
  environment = "prod"
  s3_bucket_domain_name = module.s3_prod.s3_bucket_domain_name
}

module "iam" {
  source = "./modules/iam"
  s3_buckets = [
    module.s3_dev.s3_bucket_name,
    module.s3_staging.s3_bucket_name,
    module.s3_prod.s3_bucket_name,
  ]
  cloudfront_distributions = [
    module.cloudfront_dev.cloudfront_distribution_id,
    module.cloudfront_staging.cloudfront_distribution_id,
    module.cloudfront_prod.cloudfront_distribution_id,
  ]
}
variables.tf
The variables file contains input variables used by the modules.

outputs.tf
The outputs file contains output variables exported by the modules.

Run Terraform

Install Terraform: Follow the official Terraform Installation Guide to install Terraform on your machine.
Initialize Terraform: Run terraform init in the root directory of the project to initialize Terraform and download the required providers.
Apply Terraform Changes: Run terraform apply to apply the Terraform configuration and deploy the web application infrastructure on AWS.

##Conclusion

This Terraform solution follows industry best practices for security, scalability, and code structure. It separates concerns into modules, adheres to the principle of least privilege in IAM roles, and parameterizes configurations using variables and outputs.