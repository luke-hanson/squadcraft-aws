terraform {
  backend "s3" {
    bucket = "test123-terraform-state"
    key    = "stage/terraform.tfstate"
    region = "us-east-1"
  }
}