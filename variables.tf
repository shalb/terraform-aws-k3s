variable master_instance_type {
  description = "Instance type for master nodes."
  type        = string
  default     = "t3.medium"
}

variable master_root_volume_size {
  description = "Root block device size on nodes"
  type        = number
  default     = 50
}

variable master_node_count {
  description = "Number of nodes. Should be even: 1,3,5,7.."
  default     = 3
}

variable master_security_group_ids {
  description = "A list of additional security groups to be attached to master nodes"
  type        = list(string)
  default     = []
}

variable master_additional_tags {
  description = "A list of additional tags for master nodes instances"
  type        = map(string)
  default     = {}
}

variable master_node_labels {
  description = "A list of additional labels to be added to the k3s master nodes"
  type        = list
  default     = []
}

variable master_node_taints {
  description = "A list of additional taints to be added to the k3s master nodes"
  type        = list
  default     = []
}

variable key_name {
  description = "The key name to use for the instances"
  type        = string
}

variable region {
  description = "AWS Region"
  type        = string
}

variable k3s_version {
  description = "Version of k3s engine: https://github.com/rancher/k3s/releases"
  type        = string
}

variable public_subnets {
  description = "List of public subnets to run ingress LB"
  type        = list
}


variable s3_bucket {
  description = "Kubeconfig Storage bucket"
}

variable domain {
  description = "DNS zone record to assign to NLB"
  type        = string
}

variable cluster_name {
  description = "Cluster name"
  type        = string
}

variable worker_node_groups {
  description = "A list of worker groups configs"
  default     = []
  type        = any
}

variable extra_api_args {
  description = "A list of additional arguments for kubeapi"
  type        = map
  default     = {}
}

variable master_iam_instance_profile {
  description = "IAM instance profile to be attached to master instances"
  type        = string
  default     = ""
}

variable worker_iam_instance_profile {
  description = "IAM instance profile to be attached to worker instances"
  type        = string
  default     = ""
}
