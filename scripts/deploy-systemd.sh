#!/bin/bash
# Deploy Semantic API as systemd service

DEV_EC2="44.222.168.46"
DEV_USER="ec2-user"

echo "📦 Building package..."
cd /repo/ebaejun/tools/aws/semantic-api
tar czf /tmp/semantic-api.tar.gz --exclude=node_modules --exclude=.git src/ templates/ scripts/ package.json package-lock.json semantic-api.service kiro-worker.service kiro-persistent.service

echo "📤 Uploading..."
scp /tmp/semantic-api.tar.gz $DEV_USER@$DEV_EC2:/tmp/

echo "🚀 Deploying as systemd service..."
ssh $DEV_USER@$DEV_EC2 'bash -s' << 'EOF'
# Stop existing service
sudo systemctl stop semantic-api 2>/dev/null || true

# Kill any remaining processes
sudo pkill -9 -f semantic-api-server.js || true
sudo fuser -k 9000/tcp 2>/dev/null || true
sleep 2

# Deploy
mkdir -p /home/ec2-user/semantic-api
cd /home/ec2-user/semantic-api
tar xzf /tmp/semantic-api.tar.gz
npm install --omit=dev --silent

# Install systemd services
sudo cp semantic-api.service /etc/systemd/system/
sudo cp kiro-worker.service /etc/systemd/system/
sudo cp kiro-persistent.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable semantic-api kiro-worker kiro-persistent
sudo systemctl restart semantic-api kiro-persistent kiro-worker

sleep 3
sudo systemctl status semantic-api --no-pager | head -10
sudo systemctl status kiro-persistent --no-pager | head -10
sudo systemctl stop kiro-session-pool 2>/dev/null || true
sudo systemctl disable kiro-session-pool 2>/dev/null || true
sudo systemctl start semantic-api
sudo systemctl start kiro-worker

sleep 3
sudo systemctl status semantic-api --no-pager
sudo systemctl status kiro-worker --no-pager
EOF

echo ""
echo "✅ Done!"
curl -s http://$DEV_EC2:9000/health | jq '.'
