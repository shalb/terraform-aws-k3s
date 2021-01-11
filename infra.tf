resource "aws_launch_template" "master" {
  count         = var.master_node_count
  name_prefix   = substr("${local.name}-master-${count.index}", 0, 32)
  image_id      = data.aws_ami.default_ami.id
  instance_type = var.master_instance_type
  user_data     = data.template_cloudinit_config.init-master[count.index].rendered
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.k3s_master_profile.name
  }
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted   = true
      volume_type = "gp2"
      volume_size = var.master_root_volume_size
    }
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = concat([aws_security_group.master.id], var.master_security_group_ids)
  }
  tags = local.common_tags
}

resource "aws_launch_template" "worker" {
  for_each      = local.worker_groups_map
  name_prefix   = substr("${local.name}-worker-${each.key}", 0, 32)
  image_id      = data.aws_ami.default_ami.id
  instance_type = each.value.instance_type
  user_data     = data.template_cloudinit_config.init-worker[each.key].rendered
  key_name      = var.key_name
  iam_instance_profile {
    name = var.worker_iam_instance_profile
  }
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted   = true
      volume_type = "gp2"
      volume_size = each.value.root_volume_size
    }
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = concat([aws_security_group.worker.id], each.value.additional_security_group_ids)
  }
  tags = local.common_tags
}

resource "aws_autoscaling_group" "master" {
  count               = var.master_node_count
  name_prefix         = substr("${local.name}-master-${count.index}", 0, 32)
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = var.public_subnets

  target_group_arns = [
    aws_lb_target_group.kubeapi.arn
  ]

  launch_template {
    id      = aws_launch_template.master[count.index].id
    version = "$Latest"
  }
  tags = local.master_tags

  depends_on = [
    aws_route53_record.alb_ingress,
    aws_lb.kubeapi
  ]
}

resource "aws_autoscaling_group" "worker" {
  for_each            = local.worker_groups_map
  name_prefix         = substr("${local.name}-worker-${each.key}", 0, 32)
  max_size            = each.value.max_size
  min_size            = each.value.min_size
  desired_capacity    = each.value.desired_capacity
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = aws_launch_template.worker[each.key].id
    version = "$Latest"
  }

  tags = each.value.tags

  depends_on = [
    aws_route53_record.alb_ingress,
    aws_lb.kubeapi
  ]
}
