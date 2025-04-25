variable "pve" {
    type = map(string)
    default = {
      "endpoint"          = ""
      "api_token"         = ""
      "username"          = ""
      "private_key"       = ""
      "node_name"         = ""
      "name_prefix"       = ""
      "storage_disks"     = ""
      "storage_cloudinit" = ""
      "domain"            = ""
      "dns_server"        = ""
      "vlan_id"           = ""
      "gateway"           = ""
      "cidr"              = ""
      "csi_id"            = ""
      "csi_secret"        = ""
    }
}

variable "talos" {
    type = map(string)
    default = {
      "cluster_name"    = ""
      "cp_count"        = ""
      "worker_count"    = ""
      "cp_octet"        = ""
      "worker_octet"    = "" // cp_octet + cp_count
      "cp_mem"          = ""
      "worker_mem"      = ""
      "endpoint"        = ""
      "vip"             = ""
      "environment"     = ""
    }
}

variable "kubernetes" {
  type = map(string)
  default = {
    "lb_addresspool"    = ""
    "ingress_domain"    = ""
    "ingress_lb"        = ""
  }
}

variable "cloudflare" {
  type = map(string)
  default = {
    "token"   = ""
    "zone_id" = ""
  }
}