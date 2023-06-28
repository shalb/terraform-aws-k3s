terraform {
  required_version = ">= 0.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null     = "~> 3.2"
    random   = "~> 3.4"
    template = "~> 2.2"
  }
}

provider "aws" {
  region = var.region
}
