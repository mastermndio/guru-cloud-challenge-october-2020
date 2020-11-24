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