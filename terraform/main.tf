terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

#Setup DynamoDB Table
resource "aws_dynamodb_table" "guruCCC" {
  name           = "cloudGuruChallenge"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Date"
  range_key      = "UsCases"

  attribute {
    name = "Date"
    type = "S"
  }

  attribute {
    name = "UsCases"
    type = "N"
  }

  tags = {
    Name        = "covid-dynamo"
    Environment = "production"
  }
}

#IAM role for Lambda execution
resource "aws_iam_role" "iam_role_cloudguru" {
  name = "iam_cloudguru"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#IAM Policy that allows our Lambda to Put data into DynamoDB
resource "aws_iam_policy" "lambda_dynamo_policy" {
  name        = "lambda_dynamo"
  path        = "/"
  description = "My lambda dynamo policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#Attatching Dynamodb IAM Policy to Lambda IAM Role
resource "aws_iam_policy_attachment" "dynamo_attach" {
  name       = "dynamo_attach"
  roles      = [aws_iam_role.iam_role_cloudguru.name]
  policy_arn = aws_iam_policy.lambda_dynamo_policy.arn
}

#Create Lambda Resource
resource "aws_lambda_function" "cloud_challenge_lambda" {
  filename      = "data-processor.zip"
  function_name = "cloud_challenge_processor"
  role          = aws_iam_role.iam_role_cloudguru.arn
  handler       = "lambda.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("data-processor.zip")

  runtime = "python3.8"
  timeout = 300
}

#Setup EventBridge Rule
resource "aws_cloudwatch_event_rule" "daily_processor" {
  name                = "coviDailyProcessor"
  description         = "Fires once a day"
  schedule_expression = "cron(15 10 * * ? *)"
}

resource "aws_cloudwatch_event_target" "run_covid_processor_daily" {
  rule      = aws_cloudwatch_event_rule.daily_processor.name
  target_id = "lambda"
  arn       = aws_lambda_function.cloud_challenge_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_covid_processor" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloud_challenge_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_processor.arn
}