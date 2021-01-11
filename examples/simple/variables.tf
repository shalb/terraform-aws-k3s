variable awsprofile {
  type        = string
  default     = "default"
  description = "The aws credential profile alias in ~/.aws/credentials"
}

variable azs {
  type        = list
  description = "Availability Zones to deploy cluster"
}

variable region {
  type        = string
  description = "The AWS region."
}

variable master_instance_type {
  type = string
}

variable k3s_version {
  type        = string
  description = "k3s version"
}

variable data_volume_size {
  type        = string
  default     = "50"
  description = "Instances data volume size in Gb"
}

variable key_name {
  type = string
}

variable s3_bucket {
  type = string
}

variable domain {
  type = string
}

variable cluster_name {
  type = string
}

variable worker_node_groups {
  description = "A list of worker groups configs. See description in comments"
  type        = any
}

variable master_node_labels {
  type = list
}

variable master_root_volume_size {
  type = number
}
