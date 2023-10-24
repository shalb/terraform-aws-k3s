module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "4.0.2"
  one_nat_gateway_per_az       = false
  create_egress_only_igw       = true
  azs                          = local.azs
  name                         = local.name
  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_dns_support           = true
  enable_dns_hostnames         = true
  enable_vpn_gateway           = true
  create_database_subnet_group = true
  private_subnets              = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets               = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  cidr                         = local.vpc_cidr
  public_subnet_tags = {
    "kubernetes.io/cluster/k3s-demo-boston" = "owned"
    "kubernetes.io/role/lb"                 = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/k3s-demo-boston" = "owned"
    "kubernetes.io/role/internal-lb"        = 1
  }
  map_public_ip_on_launch = true
}


module "k3s" {
  source                  = "../../"
  master_instance_type    = local.master_instance_type
  master_root_volume_size = local.master_root_volume_size
  master_node_labels      = local.master_node_labels
  cluster_name            = local.name
  region                  = local.region
  key_name                = local.key_name
  k3s_version             = local.k3s_version
  public_subnets          = module.vpc.private_subnets
  s3_bucket               = local.s3_bucket
  domain                  = local.domain
  worker_node_groups      = local.worker_node_groups
}

output "kub_config" {
  value = module.k3s.kubeconfig
}
