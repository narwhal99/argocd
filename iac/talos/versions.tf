terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.12.0"
    }
  }

  backend "s3" {
    bucket                      = "tofu"
    key                         = "tofu.tfstate"
    endpoint                    = "https://rustfs-api.raymol.com"
    region                      = "main"
    skip_region_validation      = true
    skip_credentials_validation = true
    use_path_style              = true
  }
}

provider "talos" {}