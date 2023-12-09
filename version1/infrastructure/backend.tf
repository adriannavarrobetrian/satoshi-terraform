terraform {

  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      version = ">= 5.0.0, <= 5.30.0"
      source  = "hashicorp/aws"
    }
    random = {
      version = ">= 3.5.0, <= 3.7.0"
      source  = "hashicorp/random"
    }
  }

  backend "s3" {
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  alias  = "aws"
  region = "eu-west-1"
}