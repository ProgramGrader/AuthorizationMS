// Tools used to test this infrastructure locally: Localstacks, tflocal, and awslocal
// build localStacks: docker-compose up
// pip install terraform-local
// if the tflocal or awslocal commands aren't recognized try restarting your terminal

// TODO: Fix terraform vulnerabilities
// TODO: Test terraform using terragrunt

terraform {

#   cloud{
#
#   // hostname = "app.terraform.io"
#    organization = "zacclifton"
#    workspaces {
#        name = "AuthorizationMS-dev"
#    }
#  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28"
    }
  }
#  backend "s3" { #not compatible with cloud
#    bucket = "tfstate-3ea6z45i"
#    key    = "AuthorizationMS/key"
#    region = "us-east-2"
#    dynamodb_table = "app-state"
#    encrypt = true
#  }
  
}


locals {
  shared_tags = {
    Terraform = "true"
    Project = "AuthorizationMS/key"
  }
}

#provider "aws" {
#  alias  = "primary"
#  region = var.primary_aws_region
#  access_key = var.aws_access_key
#  secret_key = var.aws_secret_key
#
#  default_tags {
#    tags = local.shared_tags
#  }
#}
#
#provider "aws" {
#  alias  = "secondary"
#  region = var.secondary_aws_region
#
#  default_tags {
#    tags = local.shared_tags
#  }
#}

data "aws_kms_key" "coreKmsENDECKeyByAlias" {
  key_id = "alias/EDKey"
}


