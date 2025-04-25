# Talos cluster on Proxmox with Terraform
Talos version - 1.9.1  
Kubernetes version - 1.32.0

# Deploy
```shell
terraform init -backend-config=state.config
terraform apply -var-file=terraform.tfvars
```

# Applications
Ingress NGINX  
Metallb  
Cilium  
CSI-Proxmox  
CCM-Proxmox  

# Setting up users/tokens in Proxmox
### Terraform
Create a user:
```shell
sudo pveum user add terraform@pve
```

Create a role for the user (you can skip this step if you want to use any of the existing roles):
```shell
sudo pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"
```

Assign the role to the previously created user:
```shell
sudo pveum aclmod / -user terraform@pve -role Terraform
```

Create an API token for the user:
```shell
sudo pveum user token add terraform@pve provider --privsep=0
```

### CSI
Create CSI role in Proxmox:
```shell
pveum role add CSI -privs "VM.Audit VM.Config.Disk Datastore.Allocate Datastore.AllocateSpace Datastore.Audit"
```

Next create a user kubernetes-csi@pve for the CSI plugin and grant it the above role
```shell
pveum user add kubernetes-csi@pve
pveum aclmod / -user kubernetes-csi@pve -role CSI
pveum user token add kubernetes-csi@pve csi -privsep 0
```

# Sources
[csi-proxmox](https://github.com/sergelogvinov/proxmox-csi-plugin/blob/main/docs/install.md)  