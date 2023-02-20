resource "aws_lb" "kubeapi" {
  name               = substr("${local.name}-kubeapi", 0, 32)
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnets
  tags               = local.common_tags
}

resource "aws_lb_listener" "kubeapi" {
  load_balancer_arn = aws_lb.kubeapi.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubeapi.arn
  }
}

resource "aws_lb_target_group" "kubeapi" {
  name     = substr("${local.name}-kubeapi", 0, 32)
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = 6443
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  stickiness {
    enabled = false
    type    = "source_ip"
  }
  tags = local.common_tags
}

resource "aws_route53_record" "controller_domain" {
  allow_overwrite = true
  zone_id         = var.zone_id
  name            = local.cluster_domain
  type            = "A"

  alias {
    name                   = aws_lb.kubeapi.dns_name
    zone_id                = aws_lb.kubeapi.zone_id
    evaluate_target_health = false
  }
}
