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
