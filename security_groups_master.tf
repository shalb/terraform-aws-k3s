resource "aws_security_group" "master" {
  name   = "${local.name}-master"
  vpc_id = data.aws_subnet.public_subnet[0].vpc_id
  depends_on = [
    null_resource.validate_domain_length
  ]
  tags = local.common_tags
}

resource "aws_security_group_rule" "allow_ssh_in_master" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "allow_kubeapi_in" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "allow_kubelet_in_master" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.master.id
  self              = true
}

resource "aws_security_group_rule" "allow_traffic_out_master" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "allow_etcd_master_self" {
  type              = "ingress"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "allow_etcd_master_worker" {
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.master.id
}

resource "aws_security_group_rule" "allow_vxlan_master_self" {
  type              = "ingress"
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
  self              = "true"
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "allow_vxlan_master_worker" {
  type                     = "ingress"
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.master.id
}

resource "aws_security_group_rule" "allow_prometheus_operator_metrics_master_self" {
  type              = "ingress"
  from_port         = 6942
  to_port           = 6942
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "allow_prometheus_operator_metrics_master_worker" {
  type                     = "ingress"
  from_port                = 6942
  to_port                  = 6942
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.master.id
}
