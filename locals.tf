locals {
  cp_ip     = [for i in range(var.talos.cp_count) : cidrhost(var.pve.cidr, var.talos.cp_octet + i)]
  worker_ip = [for i in range(var.talos.worker_count) : cidrhost(var.pve.cidr, var.talos.worker_octet + i)]
}

