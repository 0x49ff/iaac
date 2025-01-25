#!/bin/bash
terraform output -raw kubeconfig > config && mv config ~/.kube/config
terraform output -raw talosconfig > config && mv config ~/.talos/config
