terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "destination" {
  provider = aws.destination
}

provider "aws" {
  alias      = "destination"
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
  token      = ""
}

