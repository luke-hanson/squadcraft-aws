provider "aws" {
  region = "us-east-1"
}

local env = terraform.workspace

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.env}-terraform-state"

  tags = {
    Name        = "${local.env}-terraform-state"
    Environment = local.env
  }
}

resource "aws_s3_bucket_acl" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${local.env}-terraform-state-lock"
  read_capacity = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${local.env}-terraform-state-lock"
    Environment = local.env
  }
}