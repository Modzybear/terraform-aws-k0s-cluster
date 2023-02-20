locals {
  name = var.cluster_name

  cluster_domain = "k0s-${var.region}"

  controller_node_taints = var.enable_scheduling_on_controller == true ? [] : ["node-role.kubernetes.io/master:NoSchedule"]

  default_worker_instance_type    = "t3.small"
  default_worker_root_volume_size = 50

  /* worker_groups_map = {
    for worker_group_config in var.worker_groups :
    worker_group_config.name => {
      node_taints = join(" ", [
        for taint in coalescelist(lookup(worker_group_config, "node_taints", [])) :
        "--node-taint \"${taint}\""
      ])
      node_labels = join(" ", [
        for label in coalescelist(lookup(worker_group_config, "node_labels", [])) :
        "--node-label \"${label}\""
      ])
      min_size                      = worker_group_config.min_size
      max_size                      = worker_group_config.max_size
      desired_capacity              = lookup(worker_group_config, "desired_capacity", worker_group_config.min_size)
      root_volume_size              = lookup(worker_group_config, "root_volume_size", local.default_worker_root_volume_size)
      instance_type                 = lookup(worker_group_config, "instance_type", local.default_worker_instance_type)
      additional_security_group_ids = coalescelist(lookup(worker_group_config, "additional_security_group_ids", []))
      tags                          = merge(lookup(worker_group_config, "tags", {}))
    }
  } */

  common_tags = {
    "Managed" = "Terraform"
  }
}
