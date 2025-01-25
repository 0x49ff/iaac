resource "talos_machine_secrets" "this" {
    talos_version = var.talos.version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.talos.cluster_name
  cluster_endpoint = "https://${local.cp_ip[0]}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches   = [ templatefile("files/template/controlplane.yaml.tftpl", {
    vip            = var.talos.vip
    addresses      = var.kubernetes.lb_addresspool
    vlan_id        = var.pve.vlan_id
    cf_token       = var.cloudflare.token
    ingress_domain = var.kubernetes.ingress_domain
    csi_id         = var.pve.csi_id
    csi_secret     = var.pve.csi_secret
    pve_node       = var.pve.node_name
  })]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.talos.cluster_name
  cluster_endpoint = "https://${local.cp_ip[0]}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [ templatefile("files/template/worker.yaml.tftpl", {})]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.cp_ip
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [ resource.proxmox_virtual_environment_vm.controlplane ]
  count = var.talos.cp_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.cp_ip[count.index]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [ resource.proxmox_virtual_environment_vm.worker ]
  count = var.talos.worker_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = local.worker_ip[count.index]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane, talos_machine_configuration_apply.worker]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.cp_ip[0]
}

data "talos_cluster_health" "available" {
  depends_on = [ resource.proxmox_virtual_environment_vm.controlplane, resource.proxmox_virtual_environment_vm.worker ]
  
  client_configuration    = talos_machine_secrets.this.client_configuration
  control_plane_nodes     = local.cp_ip
  worker_nodes            = local.worker_ip
  endpoints               = local.cp_ip
  skip_kubernetes_checks  = true

  timeouts = {
    read = "10m"
  }
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.cp_ip[0]
}