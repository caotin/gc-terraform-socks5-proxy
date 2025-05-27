provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "core" {
  source = "../../modules/core"

  project_id = var.project_id
  region     = var.region
  zone       = var.zone
}

output "compute_instance_ip" {
  value = module.core.compute_instance_ip
}
output "mtproto_proxy_info" {
  value = module.core.mtproto_proxy_info
}
output "ssh_command" {
  value = module.core.ssh_command
}
output "mtproto_credentials_command" {
  value = module.core.mtproto_credentials_command
}

# Removed Cloud SQL output as it's not included in free tier setup
