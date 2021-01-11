data "aws_ami" "default_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

data "template_file" "init-master" {
  template = file("${path.module}/files/k3s.tpl.sh")
  count    = var.master_node_count
  vars = {
    instance_role    = "master"
    instance_index   = count.index
    k3s_server_token = random_password.k3s_server_token.result
    k3s_version      = var.k3s_version
    cluster_dns_zone = local.cluster_dns_zone
    cluster_domain   = local.cluster_domain
    s3_bucket        = var.s3_bucket
    node_labels      = local.master_node_labels
    node_taints      = local.master_node_taints
    extra_api_args   = local.extra_api_args
    kubeconfig_name  = local.kubeconfig_filename
  }
}

data "template_cloudinit_config" "init-master" {
  gzip          = true
  base64_encode = true
  count         = var.master_node_count
  part {
    content      = data.template_file.init-master[count.index].rendered
    content_type = "text/x-shellscript"
  }
}


data "template_cloudinit_config" "init-worker" {
  for_each      = local.worker_groups_map
  gzip          = true
  base64_encode = true
  part {
    content      = data.template_file.init-worker[each.key].rendered
    content_type = "text/x-shellscript"
  }
}

data "template_file" "init-worker" {
  for_each = local.worker_groups_map
  template = file("${path.module}/files/k3s.tpl.sh")
  vars = {
    instance_role    = "worker"
    instance_index   = "null"
    k3s_server_token = random_password.k3s_server_token.result
    k3s_version      = var.k3s_version
    cluster_domain   = local.cluster_domain
    node_labels      = each.value.node_labels
    node_taints      = each.value.node_taints
  }
}

resource "random_password" "k3s_server_token" {
  length  = 30
  special = false
}

data "aws_route53_zone" "main_zone" {
  name         = var.domain
  private_zone = false
}
