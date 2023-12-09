Terraform Assessment
Scenario:
A project aims to deploy a web application infrastructure on AWS through Terraform. This application requires setups across three distinct environments: development, staging, and production.


dev
staging
prod



 Your challenge involves crafting Terraform code that fulfills the given criteria, while maintaining industry best practices in security, scalability, and code structure.


Requirements:
Your task is to create Terraform code that establishes CloudFront distributions, utilizing separate Amazon S3 buckets to direct static content for each environment: dev, staging, and prod. The specific configurations are outlined below:


Development Environment:
/auth >> Bucket1_dev
/info >> Bucket2_dev
/customers >> Bucket3_dev

Staging Environment:
/auth >> Bucket1_staging
/info >> Bucket2_staging
/customers >> Bucket3_staging

Production Environment:
/auth >> Bucket1_prod
/info >> Bucket2_prod
/customers >> Bucket3_prod

Make sure that each S3 bucket adheres to versioning and server-side encryption standards using Terraform. Furthermore, implement Terraform code to establish CloudFront distributions, each directed towards its respective S3 bucket and configured for the appropriate paths:

Development Environment:
/auth >> CloudFront_Distribution1_dev
/info >> CloudFront_Distribution2_dev
/customers >> CloudFront_Distribution3_dev

Staging Environment:
/auth >> CloudFront_Distribution1_staging
/info >> CloudFront_Distribution2_staging
/customers >> CloudFront_Distribution3_staging

Production Environment:
/auth >> CloudFront_Distribution1_prod
/info >> CloudFront_Distribution2_prod
/customers >> CloudFront_Distribution3_prod

Additionally, your Terraform code should define customized IAM policies and roles for S3 bucket and CloudFront distribution access. Uphold the principle of least privilege while designing IAM roles.

To enhance maintainability and reusability, structure your Terraform code with modules. Employ variables and outputs to parameterize your configuration effectively.