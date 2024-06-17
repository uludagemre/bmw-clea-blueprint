terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      version = "~> 3.40.0"
    }
  }

  backend "s3" {
    bucket         = "my-test-tfstate"
    dynamodb_table = "my-test-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}
