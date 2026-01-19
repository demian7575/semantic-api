#!/bin/bash
set -e

# Deployment configuration
DEV_EC2="44.222.168.46"
DEV_USER="ec2-user"
PORT="8082"
APP_NAME="semantic-api"
REMOTE_DIR="/home/ec2-user/semantic-api"

echo "🚀 Deploying Semantic API to Development EC2"
echo "Target: $DEV_USER@$DEV_EC2:$PORT"

# Build deployment package
echo "📦 Creating deployment package..."
tar czf semantic-api.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  src/ \
  templates/ \
  package.json \
  package-lock.json

# Upload to EC2
echo "📤 Uploading to EC2..."
scp semantic-api.tar.gz $DEV_USER@$DEV_EC2:/tmp/

# Deploy on EC2
echo "🔧 Installing on EC2..."
ssh $DEV_USER@$DEV_EC2 << 'ENDSSH'
set -e

# Stop existing services on port 8082
echo "Stopping existing services on port 8082..."
PID=$(netstat -tlnp 2>/dev/null | grep :8082 | awk '{print $7}' | cut -d'/' -f1 | head -1)
if [ ! -z "$PID" ]; then
  kill -9 $PID 2>/dev/null || true
  sleep 1
fi

# Setup directory
mkdir -p /home/ec2-user/semantic-api
cd /home/ec2-user/semantic-api

# Extract and install
tar xzf /tmp/semantic-api.tar.gz
npm install --omit=dev

# Start with nohup
export KIRO_API_PORT=8082
export AWS_REGION=us-east-1
nohup node src/semantic-api-server.js > semantic-api.log 2>&1 &
echo $! > semantic-api.pid

sleep 2
echo "✅ Deployment complete!"
ps aux | grep semantic-api-server | grep -v grep || echo "Process not found"
ENDSSH

# Cleanup
rm semantic-api.tar.gz

# Health check
echo "🏥 Running health check..."
sleep 3
curl -f http://$DEV_EC2:$PORT/health || echo "⚠️  Health check failed"

echo ""
echo "✅ Deployment complete!"
echo "API: http://$DEV_EC2:$PORT"
echo "Health: http://$DEV_EC2:$PORT/health"
