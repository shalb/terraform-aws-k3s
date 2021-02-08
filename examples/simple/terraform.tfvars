awsprofile              = "cluster-dev"
azs                     = ["eu-central-1a", "eu-central-1b"]
region                  = "eu-central-1"
master_instance_type    = "t3.medium"
master_root_volume_size = 50
master_node_labels      = ["node-type=master"]
domain                  = "k3s-test.cluster.dev"
k3s_version             = "1.19.3+k3s1"
s3_bucket               = "cluster-dev-k3s"
cluster_name            = "k3s-test"
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
