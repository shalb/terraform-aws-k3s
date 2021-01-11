data "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)
  id    = var.public_subnets[count.index]
}

resource "aws_ec2_tag" "public_subnet_tag_cluster" {
  count       = length(var.public_subnets)
  resource_id = data.aws_subnet.public_subnet[count.index].id
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "owned"
}

resource "aws_ec2_tag" "public_subnet_tag_elb" {
  count       = length(var.public_subnets)
  resource_id = data.aws_subnet.public_subnet[count.index].id
  key         = "kubernetes.io/role/elb"
  value       = "1"
}
