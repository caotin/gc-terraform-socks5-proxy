# SOCKS5 Proxy Setup Guide

This Terraform configuration automatically installs and configures a SOCKS5 proxy server on your Google Cloud VM instance.

## What's Installed

- **Dante SOCKS5 Server**: A robust SOCKS5 proxy server
- **Random Credentials**: Automatically generated username and password
- **Firewall Rules**: Proper network access configuration
- **Management Scripts**: Easy-to-use commands for retrieving credentials

## After Deployment

### 1. Get Your VM's IP Address
After running `terraform apply`, you'll see outputs including the VM's public IP address.

### 2. SSH into Your VM
```bash
# Use the SSH command from terraform output
gcloud compute ssh main-vm --zone=<your-zone>

# Or use standard SSH if you have the IP
ssh <username>@<vm-public-ip>
```

### 3. Get SOCKS5 Credentials
Once connected to your VM, run:
```bash
sudo show-socks5-info
```

This will display:
- Username
- Password  
- Server IP
- Port (1080)
- Connection string format

### 4. Configure Your Applications

#### Browser Configuration (Firefox/Chrome)
1. Go to network/proxy settings
2. Select "Manual proxy configuration"
3. Set SOCKS Host: `<vm-public-ip>`
4. Set Port: `1080`
5. Select "SOCKS v5"
6. Enter username and password when prompted

#### Command Line Tools
```bash
# Using curl with SOCKS5 proxy
curl --socks5-hostname username:password@<vm-ip>:1080 http://httpbin.org/ip

# Using wget with SOCKS5 proxy  
wget -e use_proxy=yes -e socks_proxy=socks5://username:password@<vm-ip>:1080 http://httpbin.org/ip
```

#### SSH Tunnel
```bash
# Create a local SOCKS5 tunnel
ssh -D 8080 -N username@<vm-ip>
# Then configure applications to use localhost:8080 as SOCKS5 proxy
```

## Security Considerations

1. **Firewall**: The current setup allows connections from any IP (0.0.0.0/0). Consider restricting this to your specific IP addresses.

2. **Strong Credentials**: The system generates random credentials, but you can change them if needed:
   ```bash
   sudo passwd <socks5-username>
   ```

3. **Monitoring**: Check proxy logs:
   ```bash
   sudo journalctl -u danted -f
   ```

## Troubleshooting

### SOCKS5 Service Won't Start - Interface Configuration Issue

The most common issue preventing SOCKS5 proxy from starting is an incorrect external interface configuration in `/etc/danted.conf`.

#### Diagnose the Problem
```bash
# Check if service failed to start
sudo systemctl status danted

# Check service logs for interface errors
sudo journalctl -u danted -n 20

# Check available network interfaces
ip addr show
```

#### Fix Interface Configuration
1. **Identify the correct network interface**:
   ```bash
   # Find the main interface (usually the one with default route)
   ip route | grep default | awk '{print $5}'
   
   # Or look for interfaces with IP addresses
   ip addr show | grep -E "inet.*10\."
   ```

2. **Common interface names on Google Cloud**:
   - `ens4` (most common on newer instances)
   - `eth0` (common on older instances)
   - `enp0s3` (sometimes on certain configurations)

3. **Update the configuration**:
   ```bash
   sudo nano /etc/danted.conf
   ```
   
   Find this line:
   ```
   external: edns0
   ```
   
   Replace with the correct interface name:
   ```
   external: ens4
   ```
   (or whatever interface name you found)

4. **Restart the service**:
   ```bash
   sudo systemctl restart danted
   sudo systemctl status danted
   ```

#### Automated Fix Script
```bash
# Quick fix script - detects interface automatically
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
sudo sed -i "s/external: edns0/external: $INTERFACE/" /etc/danted.conf
sudo systemctl restart danted
echo "Updated interface to: $INTERFACE"
```

### Check if SOCKS5 service is running
```bash
sudo systemctl status danted
```

### Restart SOCKS5 service
```bash
sudo systemctl restart danted
```

### Check network connectivity
```bash
sudo netstat -tlnp | grep 1080
```

### View startup script logs
```bash
sudo journalctl -u google-startup-scripts
```

## Cost Optimization

This setup uses:
- f1-micro instance (free tier eligible)
- 10GB standard persistent disk (free tier eligible)
- Standard networking (minimal costs)

The SOCKS5 proxy runs efficiently on minimal resources and should stay within free tier limits for moderate usage.

## Connection String Format

For applications that support connection strings:
```
socks5://username:password@<vm-ip>:1080
```

Replace `username`, `password`, and `<vm-ip>` with your actual credentials and VM IP address.
