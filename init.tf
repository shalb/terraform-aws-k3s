terraform {
  required_version = ">= 0.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    null     = "~> 2.1"
    helm     = "~> 1.0"
    random   = "~> 2.2"
    template = "~> 2.1"
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host                   = local.k_config.host
    cluster_ca_certificate = local.k_config.host_cert
    client_certificate     = local.k_config.user_crt
    client_key             = local.k_config.cert_data
    load_config_file       = "false"
  }
}
