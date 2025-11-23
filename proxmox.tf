resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.pve.node_name

  url                     = "https://talos.fastcup.cloud/image/ca757c5bc571372976cf96c116ff9c22362d7226dcc5b7feb140bd53a71aae32/v${var.talos.version}/nocloud-amd64.raw.gz"
  file_name               = "talos-nocloud-amd64-${var.talos.version}.img"
  overwrite               = true
  decompression_algorithm = "gz"
}

// controlplane vm
resource "proxmox_virtual_environment_vm" "controlplane" {
  count     = var.talos.cp_count
  name      = "cp${count.index + 1}${var.pve.name_prefix}"
  tags      = ["talos", "${var.talos.cluster_name}"]
  node_name = var.pve.node_name
  vm_id     = var.pve.vm_id + count.index

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.pve.cp_mem
  }

  disk {
    datastore_id = var.pve.storage_disks
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    discard      = "on"
    ssd          = true
    interface    = "scsi0"
    size         = 50
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = var.pve.vlan_id
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = var.pve.storage_cloudinit
    ip_config {
      ipv4 {
        address = "${local.cp_ip[count.index]}/24"
        gateway = var.pve.gateway
      }
    }
    dns {
      servers = [var.pve.dns_server]
      domain  = var.pve.dns_domain
    }
  }
}

// worker vm
resource "proxmox_virtual_environment_vm" "worker" {
  depends_on = [resource.proxmox_virtual_environment_vm.controlplane]

  count     = var.talos.worker_count
  name      = "worker${count.index + 1}${var.pve.name_prefix}"
  tags      = ["talos", "${var.talos.cluster_name}"]
  node_name = var.pve.node_name
  vm_id     = var.pve.vm_id + count.index + var.talos.cp_count

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.pve.worker_mem
  }

  disk {
    datastore_id = var.pve.storage_disks
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    discard      = "on"
    ssd          = true
    interface    = "scsi0"
    size         = 50
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = var.pve.vlan_id
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = var.pve.storage_cloudinit
    ip_config {
      ipv4 {
        address = "${local.worker_ip[count.index]}/24"
        gateway = var.pve.gateway
      }
    }
    dns {
      servers = [var.pve.dns_server]
      domain  = var.pve.dns_domain
    }
  }
}