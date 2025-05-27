resource "google_compute_instance" "default" {
  name         = "main-vm"
  machine_type = "f1-micro"  # Free tier eligible
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10  # 10GB within free tier limits
      type  = "pd-standard"  # Standard persistent disk (free tier)
    }
  }

  network_interface {
    network = "default"  # Use the default network
    access_config {}     # This gives the VM an external IP
  }

  # Install and configure SOCKS5 proxy
  metadata_startup_script = <<-EOF
    #!/bin/bash
    
    # Update system
    apt-get update
    apt-get install -y dante-server curl wget net-tools
    
    # Generate random username and password for SOCKS5
    SOCKS5_USER="user$(openssl rand -hex 8)"
    SOCKS5_PASS="$(openssl rand -base64 16)"
    
    # Create SOCKS5 user
    useradd -r -s /bin/false "$SOCKS5_USER"
    echo "$SOCKS5_USER:$SOCKS5_PASS" | chpasswd
    
    # Configure Dante SOCKS5 server
    cat > /etc/danted.conf << EOL
# Dante SOCKS5 server configuration
logoutput: syslog

# Internal network interface (listen on all interfaces)
internal: 0.0.0.0 port = 1080

# External network interface
external: ens4

# Authentication method
socksmethod: username

# Client rules
clientmethod: none
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}

# SOCKS rules
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    command: bind connect udpassociate
    log: error
    socksmethod: username
}

# Block rules (optional - blocks some protocols for security)
socks block {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    command: bindreply udpreply
    log: error
}
EOL

    # Create systemd service for SOCKS5 proxy
    cat > /etc/systemd/system/socks5-proxy.service << EOL
[Unit]
Description=SOCKS5 Proxy Server (Dante)
After=network.target

[Service]
Type=forking
User=root
ExecStart=/usr/sbin/danted -f /etc/danted.conf
ExecReload=/bin/kill -HUP \$MAINPID
PIDFile=/var/run/danted.pid
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

    # Enable and start the service
    systemctl daemon-reload
    systemctl enable socks5-proxy
    systemctl start socks5-proxy
    
    # Save credentials to a file for retrieval
    SERVER_IP=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
    
    echo "SOCKS5 Proxy Credentials:" > /var/log/socks5-credentials.txt
    echo "Username: $SOCKS5_USER" >> /var/log/socks5-credentials.txt
    echo "Password: $SOCKS5_PASS" >> /var/log/socks5-credentials.txt
    echo "Server: $SERVER_IP" >> /var/log/socks5-credentials.txt
    echo "Ports: 443, 8080, 1080" >> /var/log/socks5-credentials.txt
    echo "Protocol: SOCKS5" >> /var/log/socks5-credentials.txt
    
    # Set proper permissions
    chmod 600 /var/log/socks5-credentials.txt
    
    # Also create a script to display credentials
    cat > /usr/local/bin/show-socks5-info << 'SCRIPT'
#!/bin/bash
echo "========================================="
echo "        SOCKS5 Proxy Information"
echo "========================================="
cat /var/log/socks5-credentials.txt
echo "========================================="
echo "Connection Examples:"
echo "curl --socks5-hostname $SERVER_IP:1080 --proxy-user \$USERNAME:\$PASSWORD http://example.com"
echo "ssh -D 8080 user@$SERVER_IP (for SSH tunnel)"
echo "========================================="
SCRIPT
    
    chmod +x /usr/local/bin/show-socks5-info
    
    echo "SOCKS5 proxy installation completed!" > /var/log/startup-complete.txt
  EOF

  tags = ["web", "ssh", "socks5-proxy"]
}

# Firewall rule to allow SOCKS5 proxy traffic
resource "google_compute_firewall" "allow_socks5" {
  name    = "allow-socks5-proxy"
  network = "default"  # Use the default network

  allow {
    protocol = "tcp"
    ports    = ["443", "8080", "1080"]
  }

  source_ranges = ["0.0.0.0/0"]  # Consider restricting this to specific IPs for security
  target_tags   = ["socks5-proxy"]
}

# Firewall rule to allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"  # Use the default network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
