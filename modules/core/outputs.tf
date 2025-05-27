output "compute_instance_ip" {
  description = "The public IP address of the compute instance."
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "mtproto_proxy_info" {
  description = "MTProto proxy connection information"
  value = {
    server_ip = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
    ports     = ["443", "8080", "1080"]
    protocol  = "mtproto"
    note      = "SSH into the VM and run 'sudo show-mtproto-info' to get secret and Telegram links"
    health_check = "SSH into the VM and run 'sudo systemctl status mtprotoproxy' to verify service status"
  }
}

output "ssh_command" {
  description = "SSH command to connect to the VM instance"
  value       = "gcloud compute ssh main-vm --zone=${var.zone}"
}

output "mtproto_credentials_command" {
  description = "Command to retrieve MTProto credentials after SSH"
  value       = "sudo show-mtproto-info"
}

output "debug_commands" {
  description = "Debugging commands to run via SSH"
  value = {
    health_check = "sudo systemctl status mtprotoproxy"
    view_logs = "sudo journalctl -u mtprotoproxy -f"
    service_status = "sudo systemctl status mtprotoproxy"
    port_check = "sudo netstat -tlnp | grep -E '443|8080|1080'"
    startup_complete = "sudo cat /var/log/startup-complete.txt"
  }
}

# Removed Cloud SQL outputs as it's not included in free tier setup
