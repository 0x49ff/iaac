terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
      version = "0.7.0"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.70.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.17.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.50.0"
    }
  }
  
  backend "s3" {
    bucket     = ""
    key        = ""
    workspace_key_prefix = ""

    endpoints = {}

    access_key = ""
    secret_key = ""

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

provider "proxmox" {
    endpoint  = "https://${var.pve.endpoint}:8006/"
    api_token = var.pve.api_token
    insecure  = true
    
    ssh {
        username = var.pve.username
        private_key = file(var.pve.private_key)
    }
}

provider "helm" {
  kubernetes {
    host                   = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    client_certificate     = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  }
}

provider "cloudflare" {
  api_token = var.cloudflare.token
}