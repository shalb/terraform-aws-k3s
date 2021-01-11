# AWS K3s Terraform Module

Terraform module that creates a HA [K3s Cluster](https://k3s.io/) in AWS cloud and deploys a set of core addons.

## Prerequisites


### Key Features

- [Embedded etcd](https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/#embedded-etcd-experimental) cluster with autoheal capabilities.
- Cluster [Disaster Recovery](docs/RECOVERY.md) procedures.

## Principal Diagram

![k3s diagram](docs/k3s-module-diagram.png)

## Structure

```bash
module
├── files               - cloud-config user-data
├── infra.tf            - masters and workers ASG definition
├── init.tf             - Terraform requirements
├── locals.tf           - local values and helpers
├── nlb.tf              - Load-balancer definition
├── outputs.tf          - Module outputs
├── security_groups.tf  - AWS SG list
├── variables.tf        - Terraform variables
└── iam.tf              - IAM policies
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13.4 |
| aws | ~> 3.0 |
| helm | ~> 1.0 |
| kubernetes | ~> 1.13.3 |
| null | ~> 2.1 |
| random | ~> 2.2 |
| template | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| null | ~> 2.1 |
| random | ~> 2.2 |
| template | ~> 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Cluster name | `string` | n/a | yes |
| domain | DNS zone record to assign to NLB | `string` | n/a | yes |
| extra\_api\_args | A list of additional arguments for kubeapi | `map` | `{}` | no |
| k3s\_version | Version of k3s engine: https://github.com/rancher/k3s/releases | `string` | n/a | yes |
| key\_name | The key name to use for the instances | `string` | n/a | yes |
| master\_additional\_tags | A list of additional tags for master nodes instances | `map(string)` | `{}` | no |
| master\_iam\_instance\_profile | IAM instance profile to be attached to master instances | `string` | `""` | no |
| master\_instance\_type | Instance type for master nodes. | `string` | `"t3.medium"` | no |
| master\_node\_count | Number of nodes. Should be even: 1,3,5,7.. | `number` | `3` | no |
| master\_node\_labels | A list of additional labels to be added to the k3s master nodes | `list` | `[]` | no |
| master\_node\_taints | A list of additional taints to be added to the k3s master nodes | `list` | `[]` | no |
| master\_root\_volume\_size | Root block device size on nodes | `number` | `50` | no |
| master\_security\_group\_ids | A list of additional security groups to be attached to master nodes | `list(string)` | `[]` | no |
| public\_subnets | List of public subnets to run ingress LB | `list` | n/a | yes |
| region | AWS Region | `string` | n/a | yes |
| s3\_bucket | Kubeconfig Storage bucket | `any` | n/a | yes |
| worker\_iam\_instance\_profile | IAM instance profile to be attached to worker instances | `string` | `""` | no |
| worker\_node\_groups | A list of worker groups configs | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| k8s\_nlb\_dns\_name | n/a |
| kubeconfig | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Worker node groups configuration options

`worker_node_groups` is a list of maps, each element of which describes one k3s worker nodes group and must correspond to the options described below.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Worker node group name | `string` | n/a | yes |
| max\_size | Maximum number of node in nodes group | `number` | n/a | yes |
| min\_size | Minimum number of node in nodes group | `number` | n/a | yes |
| desired\_capacity | Desired number of nodes in nodes group | `number` | `min_size` | no |
| instance\_type | Instance type wor master nodes. | `string` | `t3.medium` | no |
| root\_volume\_size | Root block device size on nodes | `number` | `100` | no |
| node\_labels | A list of additional labels to be added to the k3s nodes | `list(string)` | `[]` | no |
| node\_taints | A list of additional taints to be added to the k3s nodes | `list(string)` | `[]` | no |
| additional\_security\_group\_ids | A list of additional security groups to be attached to node group instances | `list(string)` | `[]` | no |
| tags | A list of additional tags to be attached to node group instances | `map(string)` | `{}` | no |

Example of full and minimal worker group configs:

```HCL
module "k3s" {
  source           = "git::ssh://git@github.com/shalb/terraform-aws-k3s.git"
  ... skipped for the brevity
  worker_node_groups = [
  # Full node group config.
    {
      name                          = "node_pool1"
      min_size                      = 2
      max_size                      = 5
      desired_capacity              = 2
      root_volume_size              = 50
      instance_type                 = "t3.medium"
      additional_security_group_ids = [
        "SG-EXAMPLE1",
        "SG-EXAMPLE2"
      ]
      tags = {
        tag-key1 = "value"
        tag-key2 = "value2"
      }
      node_labels = [
        "label_key=some_value",
        "foo=bar"
      ]
      node_taints = [
        "key=value:NoExecute"
        "key2=value2:NoExecute"
      ]
    },
    # Minimal node group config.
    {
      name        = "node_pool2"
      min_size    = 1
      max_size    = 1
    }
  ]

}

```
