terraform {
  backend "s3" {
    bucket = "test123-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}