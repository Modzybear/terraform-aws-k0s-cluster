variable "region" {
  type        = string
  description = "AWS region to deploy to."
  default     = "us-west-2"
}

variable "cluster_name" {
  type        = string
  description = "Name of the k0s cluster to deploy and append to related resources."
}

variable "k0s_version" {
  type = string
  default = "v1.23.6+k0s.0"
}

variable "ecr_secret_name" {
  type = string
  default = "ecr-token"
}

variable "docker_email" {
  type = string
  default = "email@email.com"
}

variable "controller_node_count" {
  type        = number
  description = "Number of controller nodes for the cluster."
  default     = 1
}

variable "controller_instance_type" {
  type        = string
  description = "AWS instance type for controller nodes."
  default     = "t3.small"
}

variable "key_name" {
  type        = string
  description = "AWS SSH key name."
  default     = ""
}

variable "controller_root_volume_size" {
  type    = number
  default = 50
}

variable "additional_controller_security_group_ids" {
  type    = list(string)
  default = []
}

variable "enable_scheduling_on_controller" {
  type    = bool
  default = true
}

variable "worker_groups" {
  type    = any
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
}

variable "zone_id" {
  type = string
}