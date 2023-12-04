terraform {
  backend "s3" {
    # bucket  = "satoshi-terraform-state-dev"
    # key     = "terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
