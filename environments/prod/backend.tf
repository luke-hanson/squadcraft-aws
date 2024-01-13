terraform {
  backend "s3" {
    bucket = "test123-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}