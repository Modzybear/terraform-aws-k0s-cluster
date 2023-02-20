resource "aws_security_group" "controller" {
  name   = "${local.name}-controller"
  vpc_id = var.vpc_id

  tags = local.common_tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "kube api"
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "etcd"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "etcd"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidr_blocks
  }
  
  ingress {
    description = "allow vxlan master self"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "allow vxlan master worker"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = var.private_subnet_cidr_blocks
  }

  ingress {
    description = "prometheus operator metrics"
    from_port   = 6942
    to_port     = 6942
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "prometheus operator metrics"
    from_port   = 6942
    to_port     = 6942
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidr_blocks
  }
}


resource "aws_security_group" "worker" {
  name   = "${local.name}-worker"
  vpc_id = var.vpc_id

  tags = local.common_tags
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "vxlan"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
  }
  ingress {
    description     = "vxlan"
    from_port       = 8472
    to_port         = 8472
    protocol        = "udp"
    security_groups = [aws_security_group.controller.id]
  }

  ingress {
    description = "prometheus operator metrics"
    from_port   = 6942
    to_port     = 6942
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description     = "prometheus operator metrics"
    from_port       = 6942
    to_port         = 6942
    protocol        = "tcp"
    security_groups = [aws_security_group.controller.id]
  }
}
