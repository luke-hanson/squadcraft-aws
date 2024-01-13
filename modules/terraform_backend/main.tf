data "aws_caller_identity" "current" {}

resource "random_string" "id" {
  count            = var.backend_id == "" ? 1 : 0
  length           = 6
  special          = false
  upper            = false
}

locals {
  id         = var.backend_id == "" ? random_string.id[0].id : var.backend_id
  account_id = data.aws_caller_identity.current.account_id
  caller_arn = data.aws_caller_identity.current.arn
}

module "terraform_state_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${local.id}-terraform-state"
  acl    = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  versioning = {
    enabled = true
  }
}

module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  name     = "${local.id}-terraform-state-lock"
  hash_key = "LockID"
  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  create_role = true
  trusted_role_arns = [
    "arn:aws:iam::${local.account_id}:root",
    local.caller_arn
  ]
  role_name         = "${local.id}-terraform"
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/Administrator"
  ]
  number_of_custom_role_policy_arns = 1
}
