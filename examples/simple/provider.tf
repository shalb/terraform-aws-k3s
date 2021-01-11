provider "aws" {
  region                  = var.region
  profile                 = var.awsprofile
  shared_credentials_file = "$HOME/.aws/credentials"
  version                 = "~> 3.0"
}
