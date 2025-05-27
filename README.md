# Google Cloud Free Tier Infrastructure with SOCKS5 Proxy - Singapore Region

This project uses a modular structure for multiple environments (dev, staging, prod).
Optimized for Google Cloud Free Tier resources in Singapore region with automatic SOCKS5 proxy setup using Dante server.

## 🚀 Features
- **SOCKS5 Proxy Server**: Automatically configured using Dante with random authentication
- **Multi-Environment Support**: Dev, staging, and production environments
- **Free Tier Optimized**: Uses only Google Cloud free tier resources
- **Singapore Region**: Optimized for asia-southeast1 region
- **Secure Setup**: Random username/password generation and proper firewall rules

## Free Tier Resources Included:
- f1-micro VM instances (Singapore: asia-southeast1)  
- 10GB standard persistent disk storage per VM
- VPC networking (free)
- Service accounts and IAM (free)
- SOCKS5 proxy server with username/password authentication

## Resources Removed for Free Tier:
- Cloud SQL (not free) - consider using Cloud Firestore for database needs
- Cloud Storage (removed to minimize costs)

## Structure

- `modules/core`: Shared infrastructure code (VPC, subnet, compute, IAM, SOCKS5 proxy)
- `envs/dev`: Development environment (Singapore region)
- `envs/staging`: Staging environment (Singapore region)
- `envs/prod`: Production environment (Singapore region)
- `deploy-socks5.sh`: Automated deployment script with credential retrieval
- `get-socks5-credentials.sh`: Script to retrieve SOCKS5 credentials from deployed VM
- `SOCKS5_PROXY_GUIDE.md`: Detailed guide for using the SOCKS5 proxy

## 🚀 Quick Start with SOCKS5 Proxy

### Option 1: Automated Deployment (Recommended)
```bash
# Deploy to dev environment
./deploy-socks5.sh dev

# Deploy to staging environment
./deploy-socks5.sh staging

# Deploy to production environment
./deploy-socks5.sh prod
```

### Option 2: Manual Deployment
1. Go to the desired environment folder:
   ```bash
   cd envs/dev
   ```

2. Update the tfvars file with your actual project ID:
   ```bash
   # Edit dev.tfvars and replace "your-dev-project-id" with your actual project ID
   ```

3. Initialize and deploy:
   ```bash
   terraform init
   terraform plan -var-file=dev.tfvars
   terraform apply -var-file=dev.tfvars
   ```

### Get SOCKS5 Credentials
After deployment, retrieve your SOCKS5 proxy credentials:
```bash
# Get credentials for any environment
./get-socks5-credentials.sh dev
./get-socks5-credentials.sh staging
./get-socks5-credentials.sh prod
```

Or manually SSH into the VM:
```bash
gcloud compute ssh main-vm --zone=asia-southeast1-a
sudo show-socks5-info
```

## 🔧 What Gets Deployed

### Infrastructure Components:
- **VPC Network**: Custom VPC with proper subnet configuration
- **VM Instance**: f1-micro instance with Debian 12
- **Firewall Rules**: SSH (port 22) and SOCKS5 (ports 443, 8080, 1080) access
- **SOCKS5 Proxy**: Dante-based SOCKS5 proxy with random username/password authentication

### Automatic Setup:
- ✅ SOCKS5 proxy server installation and configuration
- ✅ Random username and password generation
- ✅ Proper firewall configuration
- ✅ Credential storage and retrieval scripts
- ✅ Service auto-start and monitoring

## 🌐 Using Your SOCKS5 Proxy

After deployment, you can use your proxy with:
- **Web Browsers**: Configure SOCKS5 proxy settings with your server IP and credentials
- **Command Line Tools**: Use curl, wget, and other tools with SOCKS5 support
- **SSH Tunneling**: Create secure tunnels for various applications
- **Multiple Ports**: Choose from 443, 8080, or 1080 based on your network restrictions

See the SOCKS5_PROXY_GUIDE.md for detailed configuration instructions.

## Usage

## Manual Deployment (Alternative)

If you prefer manual deployment:

1. Go to the desired environment folder, e.g.:
   ```bash
   cd envs/dev
   ```

2. Update the tfvars file with your actual project ID:
   ```bash
   # Edit dev.tfvars and replace "your-dev-project-id" with your actual project ID
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan the deployment:
   ```bash
   terraform plan -var-file=dev.tfvars
   ```

5. Apply with the environment's tfvars file:
   ```bash
   terraform apply -var-file=dev.tfvars
   ```

(Replace `dev` with `staging` or `prod` as needed.)

## 📊 Cost Optimization

This setup is designed to stay within Google Cloud's Always Free tier:
- **VM Instance**: f1-micro (1 instance per month free)
- **Disk Storage**: 30GB standard persistent disk (free)
- **Network**: Egress to most regions (1GB per month free)
- **Operating System**: Debian (no licensing costs)

## 🔒 Security Features

- **Random Credentials**: Each deployment generates unique SOCKS5 username/password
- **Firewall Protection**: Only necessary ports (22, 443, 8080, 1080) are open
- **Authentication Required**: SOCKS5 proxy requires username/password for access
- **Secure Storage**: Credentials stored with restricted file permissions

## Customization
- Edit the tfvars file in each environment to set project IDs and network details.
- All environments default to Singapore region (asia-southeast1) for free tier eligibility.
- Add or override variables as needed per environment.

## Best Practices
- Use remote state (e.g., GCS backend) for production.
- Use least-privilege IAM and restrict public access.
- Regularly rotate SOCKS5 credentials by redeploying.
- Monitor proxy usage and VM performance.

## 🛠 Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `socks5-workflow.sh` | **Complete workflow** - Deploy, get credentials, and test | `./socks5-workflow.sh <env>` |
| `deploy-socks5.sh` | Deploy infrastructure with automated credential retrieval | `./deploy-socks5.sh <env>` |
| `get-socks5-credentials.sh` | Retrieve SOCKS5 credentials from deployed VM | `./get-socks5-credentials.sh <env>` |

### Script Examples
```bash
# Complete workflow (recommended for first-time setup)
./socks5-workflow.sh dev

# Just deploy infrastructure
./deploy-socks5.sh staging

# Get credentials only
./get-socks5-credentials.sh prod
```

## 📚 Documentation

- `SOCKS5_PROXY_GUIDE.md` - Detailed usage guide and troubleshooting
- `IMPLEMENTATION_SUMMARY.md` - Complete technical implementation details
- `FREE_TIER_NOTES.md` - Google Cloud free tier optimization notes

## 🔧 Troubleshooting

### SOCKS5 Proxy Won't Start

If the SOCKS5 proxy service fails to start, the most common issue is with the external interface configuration in `/etc/danted.conf`.

#### Check Network Interfaces
First, SSH into your VM and check available network interfaces:
```bash
# SSH into the VM
gcloud compute ssh main-vm --zone=asia-southeast1-a

# Check network interfaces
ip addr show
```

#### Common Interface Names
Google Cloud VMs typically use these interface names:
- `ens4` - Most common on newer instances
- `eth0` - Common on older instances
- `enp0s3` - Sometimes on certain configurations

#### Fix the Configuration
1. **Identify the correct interface**:
   ```bash
   # Look for the interface with an IP address (usually 10.x.x.x)
   ip addr show | grep -E "inet.*10\."
   ```

2. **Edit the dante configuration**:
   ```bash
   sudo nano /etc/danted.conf
   ```

3. **Update the external interface line**:
   Replace this line:
   ```
   external: edns0
   ```
   
   With the correct interface name, for example:
   ```
   external: ens4
   ```
   or
   ```
   external: eth0
   ```

4. **Restart the service**:
   ```bash
   sudo systemctl restart socks5-proxy
   sudo systemctl status socks5-proxy
   ```

#### Alternative Configuration
If you're still having issues, you can use the IP address directly:
```bash
# Get your internal IP
INTERNAL_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')

# Edit the config to use the IP instead of interface name
sudo sed -i "s/external: edns0/external: $INTERNAL_IP/" /etc/danted.conf

# Restart the service
sudo systemctl restart socks5-proxy
```

### Other Common Issues

#### Check Service Status
```bash
# Check if the service is running
sudo systemctl status socks5-proxy

# View service logs
sudo journalctl -u socks5-proxy -f

# Check if the port is listening
sudo netstat -tlnp | grep 1080
```

#### Firewall Issues
```bash
# Check if firewall rules are applied
gcloud compute firewall-rules list --filter="name:allow-socks5-proxy"

# Test connectivity from outside
# (Run this from your local machine)
telnet YOUR_VM_IP 1080
```

#### VM Startup Script Logs
```bash
# Check startup script execution
sudo journalctl -u google-startup-scripts

# Check if credentials file was created
sudo cat /var/log/socks5-credentials.txt
```

## 🔄 Manual Interface Detection Script

If you want to automate the interface detection, you can run this script on the VM:

```bash
# Create and run interface detection script
cat > fix_dante_interface.sh << 'EOF'
#!/bin/bash

echo "Detecting network interface..."

# Find the main network interface (with default route)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

if [ -z "$INTERFACE" ]; then
    echo "Could not detect network interface automatically."
    echo "Available interfaces:"
    ip addr show | grep -E "^[0-9]+:" | cut -d: -f2 | tr -d ' '
    exit 1
fi

echo "Detected interface: $INTERFACE"

# Backup original config
sudo cp /etc/danted.conf /etc/danted.conf.backup

# Update the configuration
sudo sed -i "s/external: edns0/external: $INTERFACE/" /etc/danted.conf

echo "Updated /etc/danted.conf with interface: $INTERFACE"

# Restart the service
echo "Restarting SOCKS5 proxy service..."
sudo systemctl restart socks5-proxy

# Check status
sudo systemctl status socks5-proxy --no-pager

echo "Done! Check the service status above."
EOF

chmod +x fix_dante_interface.sh
sudo ./fix_dante_interface.sh
```
## Best Practices

- Use remote state (e.g., GCS backend) for production
- Use least-privilege IAM and restrict public access
- Regularly rotate SOCKS5 credentials by redeploying
- Monitor proxy usage and VM performance
- Always check `/etc/danted.conf` external interface configuration if proxy fails to start
- Use modules for DRY and scalable infrastructure
- Stay within free tier limits: 1 f1-micro instance per month in eligible regions
- Monitor usage to avoid unexpected charges

## Free Tier Limits
See `FREE_TIER_SINGAPORE.md` for detailed information about Singapore region free tier limits and cost optimization tips.
