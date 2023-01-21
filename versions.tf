terraform {
  required_version = ">= 1.3.7"
  required_providers {
    aws = ">= 4.51.0"
  }
  backend "s3" {
    bucket = "squadcraft-terraform-state"
    key    = "squadcraft.tfstate"
    region = "us-east-1"
    dynamodb_table = "${local.env}-terraform-state-lock"
  }
}
