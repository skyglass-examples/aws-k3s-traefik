terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"      
    }
  }
}

provider "aws" {
    region =                  "${var.aws_region}"
    shared_credentials_file = "/Users/skliarm/.aws/credentials"
    profile                 = "ops-account"   
}