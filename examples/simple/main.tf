module "k3s" {
  source                  = "../../"
  master_instance_type    = var.master_instance_type
  master_root_volume_size = var.master_root_volume_size
  master_node_labels      = var.master_node_labels
  cluster_name            = var.cluster_name
  region                  = var.region
  key_name                = var.key_name
  k3s_version             = var.k3s_version
  public_subnets          = ["subnet-6696651a"]
  s3_bucket               = var.s3_bucket
  domain                  = var.domain
  worker_node_groups      = var.worker_node_groups
}

output "kub_config" {
  value = module.k3s.kubeconfig
}
