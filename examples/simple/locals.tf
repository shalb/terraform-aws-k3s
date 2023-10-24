data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  name            = "k3s-test"
  region = "eu-central-1"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Example = local.name
  }
  master_node_labels      = ["node-type=master"]
  awsprofile              = "cluster-dev"
  master_instance_type    = "t3.medium"
  master_root_volume_size = 50
  domain                  = "k3s-test.cluster.dev"
  k3s_version             = "1.25.11+k3s1"
  s3_bucket               = "cluster-dev-k3s"
  key_name                = "arti-key"
  worker_node_groups      = []
  extra_api_args = {
    oidc-issuer-url     = "https://example.com/my"
    oidc-username-claim = "email"
    oidc-groups-claim   = "groups"
    oidc-client-id      = "login"
    allow-privileged    = "true"
  }
  extra_args = [
    "--disable traefik"
  ]

}