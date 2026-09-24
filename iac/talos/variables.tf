variable talos_version {
  type = string
}

variable kubernetes_version {
  type = string
}

variable cluster_name {
  type = string
}

variable cluster_endpoint {
  type = string
}

variable talos_extensions {
  type    = list(string)
  default = []
}

variable controlplane_nodes {
    type = map(object({
      ip = string
    }))
}

variable worker_nodes {
    type = map(object({
      ip = string
    }))
}