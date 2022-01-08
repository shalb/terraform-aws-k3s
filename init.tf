terraform {
  required_version = ">= 0.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    null     = "~> 2.1"
    random   = "~> 2.2"
    template = "~> 2.1"
  }
}

provider "aws" {
  region = var.region
}
