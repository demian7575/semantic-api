#!/bin/bash
set -e

echo "🚀 Setting up EC2 instance for Kiro API..."

# Update system
sudo yum update -y

# Install Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install nginx
sudo yum install -y nginx

# Install git
sudo yum install -y git

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Create application directory
sudo mkdir -p /opt/kiro-api
sudo chown ec2-user:ec2-user /opt/kiro-api

# Clone repository
cd /opt/kiro-api
git clone <your-repo-url> .

# Install dependencies
npm install

# Copy nginx configuration
sudo cp infrastructure/nginx.conf /etc/nginx/conf.d/kiro-api.conf
sudo nginx -t

# Create systemd service
sudo cp systemd/kiro-api.service /etc/systemd/system/
sudo systemctl daemon-reload

# Enable and start services
sudo systemctl enable nginx
sudo systemctl enable kiro-api
sudo systemctl start nginx
sudo systemctl start kiro-api

echo "✅ EC2 setup complete!"
echo "📊 Check status:"
echo "  sudo systemctl status kiro-api"
echo "  sudo systemctl status nginx"
echo "  curl http://localhost:8081/health"
