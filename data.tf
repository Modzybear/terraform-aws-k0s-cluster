data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "template_file" "init_controller" {
  count               = var.controller_node_count
  template = file("${path.module}/files/install-k0s.sh")
  vars = {
    k0s_version = var.k0s_version
    region = var.region
    ecr_secret_name = var.ecr_secret_name
    aws_account = data.aws_caller_identity.current.account_id
    docker_email = var.docker_email
  }
}

data "template_cloudinit_config" "init_controller" {
  count               = var.controller_node_count
  gzip          = true
  base64_encode = true
  part {
    content      = data.template_file.init_controller[count.index].rendered
    content_type = "text/x-shellscript"
  }
}

/* data "template_file" "init_worker" {
  for_each = local.worker_groups_map
  template = file("${path.module}/files/k3s.tpl.sh")
  vars = {
    instance_role  = "worker"
    instance_index = "null"
    k0s_version    = each.value.k0s_version
    cluster_domain = local.cluster_domain
    node_labels    = each.value.node_labels
    node_taints    = each.value.node_taints
  }
}

data "template_cloudinit_config" "init_worker" {
  for_each      = local.worker_groups_map
  gzip          = true
  base64_encode = true
  part {
    content      = data.template_file.init_worker[each.key].rendered
    content_type = "text/x-shellscript"
  }
} */
