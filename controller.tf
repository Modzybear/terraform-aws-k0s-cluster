resource "aws_launch_template" "controller" {
  count         = var.controller_node_count
  name_prefix   = substr("${local.name}-controller-${count.index}", 0, 32)
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.controller_instance_type
  user_data     = data.template_cloudinit_config.init_controller[count.index].rendered
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.controller.name
  }
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted   = true
      volume_type = "gp2"
      volume_size = var.controller_root_volume_size
    }
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = concat([aws_security_group.controller.id], var.additional_controller_security_group_ids)
  }
  tags = local.common_tags
}

resource "aws_autoscaling_group" "controller" {
  count               = var.controller_node_count
  name_prefix         = substr("${local.name}-controller-${count.index}", 0, 32)
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = var.private_subnets

  target_group_arns = [
    aws_lb_target_group.kubeapi.arn
  ]

  launch_template {
    id      = aws_launch_template.controller[count.index].id
    version = "$Latest"
  }
}
