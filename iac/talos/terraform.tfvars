talos_version          = "v1.13.7"
kubernetes_version     = "v1.36.2"
cluster_name           = "talos-cluster"
cluster_endpoint       = "https://k8s-api.raymol.com:6443"
talos_extensions       = [
  "qemu-guest-agent",
  "iscsi-tools",
  "util-linux-tools"
]
controlplane_nodes = {
  vmtalcp01 = { ip = "10.20.0.42" },
  vmtalcp02 = { ip = "10.20.0.43" },
  vmtalcp03 = { ip = "10.20.0.44" }
}
worker_nodes = {
  vmtalwn01 = { ip = "10.20.0.45" },
  vmtalwn02 = { ip = "10.20.0.46" }
}