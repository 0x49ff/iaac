variable "pve" {
  type = object({
    endpoint          = string
    api_token         = string
    username          = string
    private_key       = string
    node_name         = string
    cluster_name      = string
    name_prefix       = string
    vm_id             = string
    storage_disks     = string
    storage_cloudinit = string
    cp_mem            = number
    worker_mem        = number
    dns_domain        = string
    dns_server        = string
    vlan_id           = number
    gateway           = string
    cidr              = string
    csi_id            = string
    csi_secret        = string
    ccm_id            = string
    ccm_secret        = string
  })
}

variable "talos" {
  type = object({
    cluster_name = string
    cp_count     = number
    worker_count = number
    cp_octet     = number
    worker_octet = number
    endpoint     = string
    vip          = string
    version      = string
  })
}

variable "kubernetes" {
  type = object({
    lb_addresspool  = string
    ingress_domain  = string
    ingress_lb      = string
    cilium_version  = string
    nginx_version   = string
    metallb_version = string
  })
}

variable "cloudflare" {
  type = object({
    token   = string
    zone_id = string
  })
}

variable "storage_classes" {
  type = list(object({
    name    = string
    storage = string
    type    = string
    fstype  = optional(string, "ext4")
  }))

  default = []

  validation {
    condition = alltrue([
      for sc in var.storage_classes : contains(["ssd", "hdd"], sc.type)
    ])
    error_message = "Storage type must be 'ssd' or 'hdd'"
  }
}