provider "aws" {
  region = "us-east-1"
}

local env = terraform.workspace

data "aws_ami" "al2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon/amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["572312708711"]
}

resource "aws_instance" "minecraft_server" {
  ami           = data.aws_ami.al2.id
  instance_type = "t3.medium"
  tags = {
    Name = "${local.env}-minecraft-server"
    backup = "Backup"
  }
}

resource "aws_eip" "minecraft_server_public_address" {
  vpc = true
}

resource "aws_eip_association" "public_address_association" {
  instance_id   = aws_instance.minecraft_server.id
  allocation_id = aws_eip.minecraft_server_public_address.id
}

resource "aws_iam_role" "lambda" {
  name = "${local.env}-lambda"
  assume_role_policy = templatefile(policies/lambda_role.json){}
}

resource "aws_lambda_function" "create_ami" {
  filename      = "create-ami.zip"
  function_name = "${local.env}-create-ami"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.6"
}

resource "aws_lambda_function" "delete_ami" {
  filename      = "delete-ami.zip"
  function_name = "${local.env}-delete-ami"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.6"
}

resource "aws_lambda_function" "start_server" {
  filename      = "start-server.zip"
  function_name = "${local.env}-start-server"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
}

resource "aws_lambda_function" "stop_server" {
  filename      = "stop-server.zip"
  function_name = "${local.env}-stop-server"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
}

resource "aws_cloudwatch_event_rule" "start_server" {
  name        = "${local.env}-start-server"
  schedule_expression = "cron(0 23 * * ? *)"
}

resource "aws_lambda_permission" "start_server" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_server.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_server.arn
}