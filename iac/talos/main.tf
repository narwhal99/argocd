locals {
  domain               = "raymol.com"
  controlplane_patches = {
    for name, node in var.controlplane_nodes : name => compact([
      file("${path.module}/patches/common.yaml"),
      file("${path.module}/patches/controlplane.yaml"),
      templatefile("${path.module}/templates/hostname-config.yaml.tftpl", {hostname = "${name}.${local.domain}"}),
      try(file("${path.module}/patches/nodes/${name}.yaml"), ""),
      yamlencode({
        machine = {
          install = {
            image = "factory.talos.dev/installer/${data.talos_image_factory_urls.this.urls.installer}"
          }
        }
      })
    ])
  }

  worker_patches       = {
    for name, node in var.worker_nodes : name => compact([
      file("${path.module}/patches/common.yaml"),
      file("${path.module}/patches/worker.yaml"),
      templatefile("${path.module}/templates/hostname-config.yaml.tftpl", {hostname = "${name}.${local.domain}"}),
      try(file("${path.module}/patches/nodes/${name}.yaml"), ""),
      yamlencode({
        machine = {
          install = {
            image = "factory.talos.dev/installer/${data.talos_image_factory_urls.this.urls.installer}"
          }
        }
      })
    ])
  }
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = var.talos_extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
      }
    }
  })
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "metal"
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  for_each           = var.controlplane_nodes

  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version

  config_patches = local.controlplane_patches[each.key]
}

data "talos_machine_configuration" "worker" {
  for_each           = var.worker_nodes

  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version

  config_patches = local.worker_patches[each.key]
}


resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = var.controlplane_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[each.key].machine_configuration
  node                        = each.value.ip
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = var.worker_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  node                        = each.value.ip
}
