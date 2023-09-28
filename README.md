# AWS K3s Terraform Module

[![Cluster.dev logo](https://raw.githubusercontent.com/shalb/cluster.dev/master/docs/images/cdev-module-banner.png?sanitize=true)](https://cluster.dev/)

Terraform module that creates a [K3s Cluster](https://k3s.io/) with core add-ons in AWS cloud.

This Terraform module is also used as part of the [AWS-K3s Cluster.dev stack template](https://github.com/shalb/cdev-aws-k3s) to start and provision a K3s cluster with add-ons in AWS cloud. 

## Features

The module creates a high-availability K3s cluster in AWS cloud and deploys to the cluster the following add-ons:

1. **Cert-Manager**: Automate the management and issuance of TLS certificates for your applications.
   
2. **Ingress-Nginx**: A high-performance, production-ready HTTP and HTTPS Ingress controller for Kubernetes.
   
3. **External-DNS**: Automatically configure DNS records for your Kubernetes services.

4. **Argo CD**: Continuous Delivery for Kubernetes.

## Usage

To use this Terraform module to provision a K3s cluster with the specified add-ons, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/shalb/terraform-aws-k3s.git
   ```

2. **Configure variables**: Customize your K3s cluster configuration by either creating a `terraform.tfvars` file or providing variables inline. For example:
   ```hcl
   # Cluster Configuration
   cluster_name = "my-k3s-cluster"
   region       = "us-east-1"

   # Node Configuration
   node_instance_type = "t3.medium"
   node_count         = 3

   # Networking
   vpc_id            = "vpc-0123456789abcdef0"
   subnets           = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
   ```
   
3. **Apply the configuration**:
   ```hcl
   terraform apply
   ```

4. **Access the K3s cluster**: After the provisioning is complete, you can access your K3s cluster using the K3s CLI or `kubectl` configured to use the K3s cluster context.
 
5. **Manage and deploy applications**: Utilize the K3s cluster for deploying, managing, and scaling your containerized applications.   

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.4 |
| aws | ~> 3.0 |
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
| enable\_asg\_rolling\_auto\_update | Turn on/off automatic rolling update of worker ASGs, when launch configuration changed. | `bool` | `false` | no |
| enable\_scheduling\_on\_master | Allows running pods on master nodes. | `bool` | `false` | no |
| extra\_api\_args | A map of additional arguments for kubeapi. Key - argument without --, and it value. See examples. | `map(any)` | `{}` | no |
| extra\_args | A list of additional arguments for k3s server | `list(any)` | `[]` | no |
| k3s\_version | Version of k3s engine: https://github.com/rancher/k3s/releases | `string` | n/a | yes |
| key\_name | The key name to use for the instances | `string` | n/a | yes |
| master\_additional\_tags | A list of additional tags for master nodes instances | `map(string)` | `{}` | no |
| master\_iam\_policies | A list of IAM policies ARNs to be attached to master instances | `list(string)` | `[]` | no |
| master\_instance\_type | Instance type for master nodes. | `string` | `"t3.medium"` | no |
| master\_node\_count | Number of nodes. Should be even: 1,3,5,7.. | `number` | `3` | no |
| master\_node\_labels | A list of additional labels to be added to the k3s master nodes | `list(any)` | `[]` | no |
| master\_node\_taints | A list of additional taints to be added to the k3s master nodes | `list(any)` | `[]` | no |
| master\_root\_volume\_size | Root block device size on nodes | `number` | `50` | no |
| master\_security\_group\_ids | A list of additional security groups to be attached to master nodes | `list(string)` | `[]` | no |
| public\_subnets | List of public subnets to run ingress LB | `list(any)` | n/a | yes |
| region | AWS Region | `string` | n/a | yes |
| s3\_bucket | Kubeconfig Storage bucket | `any` | n/a | yes |
| worker\_iam\_policies | A list of IAM policies ARNs to be attached to all worker instances | `list(string)` | `[]` | no |
| worker\_node\_groups | A list of worker groups configs | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate\_authority | The base64 encoded certificate data required to communicate with cluster. Add this to the certificate-authority-data section of the kubeconfig file for cluster. |
| client\_certificate | The base64 encoded client-certificate-data required to communicate with cluster. |
| client\_key\_data | The base64 encoded client-key-data required to communicate with cluster. |
| endpoint | The endpoint for Kubernetes API server. |
| k8s\_nlb\_dns\_name | n/a |
| kubeconfig | n/a |
| kubeconfig\_s3\_url | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Worker nodes groups configuration options

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

## ASG rolling update
### Concept
Soft: https://github.com/deitch/aws-asg-roller

The update methodology:

1) Increment desired setting (The max node count value for the ASG must be higher than desired).
2) Watch the new node come online. Also checks that a new node has appeared in the cluster and has the "ready" status.
3) When new node is ready, select one old node, drain from kubernetes cluster and then terminate it.
4) Repeat until the number of nodes with the correct configuration or template matches the original desired setting. At this point, there is likely to be one old node left.
6) Decrement the desired setting.

### How to run
ASG rolling update does not require additional actions from the user. If the option `enable_asg_rolling_auto_update` is set to true, the update process will be launched automatically after changing the launch configuration of the ASG.

### IAM policies
AWS ASG Roller will be launched on master nodes and requires following IAM rights:
```
 - Effect: Allow
   Action:
   - "autoscaling:DescribeAutoScalingGroups"
   - "autoscaling:DescribeAutoScalingInstances"
   - "autoscaling:SetDesiredCapacity"
   - "autoscaling:TerminateInstanceInAutoScalingGroup"
   - "autoscaling:UpdateAutoScalingGroup"
   - "autoscaling:DescribeTags"
   - "autoscaling:DescribeLaunchConfigurations"
   - "ec2:DescribeLaunchTemplates"
   - "ec2:DescribeInstances"
   - "autoscaling:CreateOrUpdateTags"
   Resource: "*"
```
