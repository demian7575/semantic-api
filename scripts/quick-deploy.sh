#!/bin/bash
# Simple deployment - assumes port 8082 is free or manually cleared

DEV_EC2="44.222.168.46"
DEV_USER="ec2-user"

echo "📦 Building package..."
cd /repo/ebaejun/tools/aws/semantic-api
tar czf /tmp/semantic-api.tar.gz --exclude=node_modules --exclude=.git src/ templates/ package.json package-lock.json

echo "📤 Uploading..."
scp /tmp/semantic-api.tar.gz $DEV_USER@$DEV_EC2:/tmp/

echo "🚀 Deploying..."
ssh $DEV_USER@$DEV_EC2 'bash -s' << 'EOF'
# Kill old process
pkill -9 -f semantic-api-server.js || true
sleep 1

# Deploy
cd /home/ec2-user/semantic-api || mkdir -p /home/ec2-user/semantic-api && cd /home/ec2-user/semantic-api
tar xzf /tmp/semantic-api.tar.gz
npm install --omit=dev --silent

# Start
KIRO_API_PORT=8082 AWS_REGION=us-east-1 nohup node src/semantic-api-server.js > semantic-api.log 2>&1 &
sleep 2
EOF

echo "✅ Done!"
curl -s http://$DEV_EC2:8082/health | jq '.'
