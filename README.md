# Talos cluster on Proxmox with Terraform
Talos version - 1.11.5  
Kubernetes version - 1.34.0

# Deploy
```shell
terraform init -backend-config=state.config
terraform apply -var-file=terraform.tfvars
```

# Deployments
Ingress NGINX  
Metallb  
Cilium  
CSI-Proxmox  
CCM-Proxmox  

# Setting up users/tokens in Proxmox
# Terraform
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

# CSI, CCM
Create CSI/CCM role in Proxmox:
```shell
pveum role add CSI -privs "VM.Audit VM.Config.Disk Datastore.Allocate Datastore.AllocateSpace Datastore.Audit Sys.Audit"
pveum role add CCM -privs "VM.Audit Sys.Audit"
```

Next create a users csi@pve/ccm@pve for the CSI and CCM plugin, grant it the above role
```shell
pveum user add csi@pve
pveum user add ccm@pve

pveum aclmod / -user csi@pve -role CSI
pveum aclmod / -user ccm@pve -role CCM

pveum user token add csi@pve csi -privsep 0
pveum user token add ccm@pve ccm -privsep 0
```

# Sources
[csi-proxmox](https://github.com/sergelogvinov/proxmox-csi-plugin/)  
[ccm-proxmox](https://github.com/sergelogvinov/proxmox-cloud-controller-manager)