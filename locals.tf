
locals {
  name                   = var.cluster_name
  cluster_domain         = "cp.${var.domain}"
  s3_kubeconfig_filename = "kubeconfig"
  common_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    KubernetesCluster                           = var.cluster_name
  }
  default_worker_instance_type    = "t3.medium"
  default_worker_root_volume_size = 50
  default_worker_node_labels = [
    #  "node-role.kubernetes.io/worker=true"
  ]
  default_master_node_taints = var.enable_scheduling_on_master == true ? [] : ["node-role.kubernetes.io/master:NoSchedule"]
  worker_groups_map = {
    for node_group_config in var.worker_node_groups :
    node_group_config.name => {
      # Use sort() function to make sure the variable is a list.
      node_taints = join(" ",
        [for taint in sort(lookup(node_group_config, "node_taints", [])) :
          "--node-taint \"${taint}\""
      ])
      node_labels = join(" ",
        [for label in concat(sort(lookup(node_group_config, "node_labels", [])), local.default_worker_node_labels) :
          "--node-label \"${label}\""
      ])
      min_size                      = node_group_config.min_size
      max_size                      = node_group_config.max_size
      desired_capacity              = lookup(node_group_config, "desired_capacity", node_group_config.min_size)
      root_volume_size              = lookup(node_group_config, "root_volume_size", local.default_worker_root_volume_size)
      instance_type                 = lookup(node_group_config, "instance_type", local.default_worker_instance_type)
      additional_security_group_ids = sort(lookup(node_group_config, "additional_security_group_ids", []))
      tags = [
        for tag_key, tag_val in merge(lookup(node_group_config, "tags", {}), local.common_tags, { Name = node_group_config.name }) :
        {
          key                 = tag_key
          value               = tag_val
          propagate_at_launch = true
        }
      ]
    }
  }

  master_tags = [
    for tag_key, tag_val in merge(var.master_additional_tags, local.common_tags, { Name = "${var.cluster_name}-master" }) : {
      key                 = tag_key
      value               = tag_val
      propagate_at_launch = true
    }
  ]
  master_node_labels = join(" ",
    [for label in var.master_node_labels :
      "--node-label \"${label}\""
  ])
  master_node_taints = join(" ",
    [for taint in concat(var.master_node_taints, local.default_master_node_taints) :
      "--node-taint \"${taint}\""
  ])
  extra_api_args = join(" ",
    [for key, value in var.extra_api_args :
      "--kube-apiserver-arg \"${key}=${value}\""
  ])
  custom_args = join(" ", var.extra_args)

  master_iam_policy_default = file("${path.module}/policies/master.json")
  worker_iam_policy_default = file("${path.module}/policies/worker.json")
}

resource "null_resource" "validate_domain_length" {
  provisioner "local-exec" {
    command = "if [ ${length(local.cluster_domain)} -ge 38 ]; then echo \"ERR: \nThe length of the domain for kubeapi (domain:${local.cluster_domain}, length:${length(local.cluster_domain)}) must not exceed 37 characters.\nDomain name includes variables 'var.cluster_name' (${var.cluster_name}) and 'var.domain' (${var.domain}).\nCheck the length of these variables.\" ; exit 1; fi"
  }
}
