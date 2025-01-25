resource "helm_release" "cilium" {
  depends_on = [ data.talos_cluster_health.available ]

  namespace  = "cilium"
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.16.4"

  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }
  
  set {
    name  = "kubeProxyReplacement"
    value = "true"
  }

  set {
    name  = "securityContext.capabilities.ciliumAgent"
    value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  }

  set {
    name  = "securityContext.capabilities.cleanCiliumState"
    value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
  }

  set {
    name  = "cgroup.autoMount.enabled"
    value = "false"
  }

  set {
    name  = "cgroup.hostRoot"
    value = "/sys/fs/cgroup"
  }

  set {
    name  = "k8sServiceHost"
    value = "localhost"  
  }

  set {
    name  = "k8sServicePort"
    value = "7445"
  }

}

resource "helm_release" "metallb" {
  depends_on  = [ resource.helm_release.cilium ]

  namespace   = "metallb-system"
  name        = "metallb"
  repository  = "https://metallb.github.io/metallb"
  chart       = "metallb"
  version     = "0.14.9"
}

resource "helm_release" "ingress_nginx" {
  depends_on  = [ resource.helm_release.metallb ]

  namespace   = "ingress-nginx"
  name        = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  version     = "4.12.0"

  set {
    name      = "controller.replicaCount"
    value     = "3"
  }
  set {
    name      = "controller.service.loadBalancerIP"
    value     = var.kubernetes.ingress_lb
  }
  set {
    name      = "controller.allowSnipperAnnotations"
    value     = true
  }
}

resource "cloudflare_record" "a" {
  name    = var.kubernetes.ingress_domain
  type    = "A"
  zone_id = var.cloudflare.zone_id
  content = var.kubernetes.ingress_lb
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "cname" {
  name    = "*.${var.kubernetes.ingress_domain}"
  type    = "CNAME"
  zone_id = var.cloudflare.zone_id
  content = var.kubernetes.ingress_domain
  ttl     = 3600
  proxied = false
}

resource "helm_release" "cert-manager" {
  depends_on = [ resource.cloudflare_record.a, resource.cloudflare_record.cname, resource.helm_release.ingress_nginx ]

  namespace  = "cert-manager"
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.16.2"

  set {
    name     = "crds.enabled"
    value    = "true"
  }
}