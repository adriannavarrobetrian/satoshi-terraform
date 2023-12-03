terraform {
  backend "s3" {
    bucket  = "terraform-state-satoshi-dev"
    key     = "terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
