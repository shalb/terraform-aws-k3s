variable "master_instance_type" {
  description = "Instance type for master nodes."
  type        = string
  default     = "t3.medium"
}

variable "master_root_volume_size" {
  description = "Root block device size on nodes"
  type        = number
  default     = 50
}

variable "master_node_count" {
  description = "Number of nodes. Should be even: 1,3,5,7.."
  default     = 3
}

variable "master_security_group_ids" {
  description = "A list of additional security groups to be attached to master nodes"
  type        = list(string)
  default     = []
}

variable "master_additional_tags" {
  description = "A list of additional tags for master nodes instances"
  type        = map(string)
  default     = {}
}

variable "master_node_labels" {
  description = "A list of additional labels to be added to the k3s master nodes"
  type        = list(any)
  default     = []
}

variable "master_node_taints" {
  description = "A list of additional taints to be added to the k3s master nodes"
  type        = list(any)
  default     = []
}

variable "key_name" {
  description = "The key name to use for the instances"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "k3s_version" {
  description = "Version of k3s engine: https://github.com/rancher/k3s/releases"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets to run ingress LB"
  type        = list(any)
}


variable "s3_bucket" {
  description = "Kubeconfig Storage bucket"
}

variable "domain" {
  description = "DNS zone record to assign to NLB"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "worker_node_groups" {
  description = "A list of worker groups configs"
  default     = []
  type        = any
}

variable "extra_api_args" {
  description = "A map of additional arguments for kubeapi. Key - argument without --, and it value. See examples."
  type        = map(any)
  default     = {}
}

variable "extra_args" {
  description = "A list of additional arguments for k3s server"
  type        = list(any)
  default     = []
}


variable "master_iam_policies" {
  description = "A list of IAM policies ARNs to be attached to master instances"
  type        = list(string)
  default     = []
}

variable "worker_iam_policies" {
  description = "A list of IAM policies ARNs to be attached to all worker instances"
  type        = list(string)
  default     = []
}


variable "enable_asg_rolling_auto_update" {
  description = "Turn on/off automatic rolling update of worker ASGs, when launch configuration changed."
  type        = bool
  default     = false
}

variable "enable_scheduling_on_master" {
  description = "Allows running pods on master nodes."
  type        = bool
  default     = false
}
