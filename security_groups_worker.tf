resource "aws_security_group" "worker" {
  name   = "${local.name}-worker"
  vpc_id = data.aws_subnet.public_subnet[0].vpc_id
  depends_on = [
    null_resource.validate_domain_length
  ]
  tags = local.common_tags
}

resource "aws_security_group_rule" "allow_ssh_in_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_kubelet_in_worker" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_traffic_out_worker" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_vxlan_worker_self" {
  type              = "ingress"
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
  self              = "true"
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_vxlan_worker_master" {
  type                     = "ingress"
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_cilium_healthcheck_worker_self_tcp" {
  type              = "ingress"
  from_port         = 4240
  to_port           = 4240
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_cilium_healthcheck_worker_master_tcp" {
  type                     = "ingress"
  from_port                = 4240
  to_port                  = 4240
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_cilium_healthcheck_worker_self_icmp" {
  type              = "ingress"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  self              = "true"
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_cilium_healthcheck_worker_worker_icmp" {
  type                     = "ingress"
  from_port                = 8
  to_port                  = 0
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_prometheus_operator_metrics_worker_self" {
  type              = "ingress"
  from_port         = 6942
  to_port           = 6942
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_prometheus_operator_metrics_worker_master" {
  type                     = "ingress"
  from_port                = 6942
  to_port                  = 6942
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_cilium_agent_metrics_worker_self" {
  type              = "ingress"
  from_port         = 9876
  to_port           = 9876
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_cilium_agent_metrics_worker_master" {
  type                     = "ingress"
  from_port                = 9876
  to_port                  = 9876
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_cilium_agent_healthcheck_worker_self" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_cilium_agent_healthcheck_worker_master" {
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.worker.id
}
