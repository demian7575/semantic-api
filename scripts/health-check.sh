#!/bin/bash

# Load environment
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

echo "🏥 Checking Kiro API health..."

# Check EC2 connectivity
echo "1. Checking EC2 connectivity..."
if ssh -i $EC2_KEY_PATH -o ConnectTimeout=5 ec2-user@$EC2_PUBLIC_IP "echo 'Connected'" > /dev/null 2>&1; then
  echo "   ✅ EC2 accessible"
else
  echo "   ❌ EC2 not accessible"
  exit 1
fi

# Check services
echo "2. Checking systemd services..."
ssh -i $EC2_KEY_PATH ec2-user@$EC2_PUBLIC_IP << 'EOF'
  # Check Kiro API
  if systemctl is-active --quiet kiro-api; then
    echo "   ✅ kiro-api service running"
  else
    echo "   ❌ kiro-api service not running"
    sudo systemctl status kiro-api
    exit 1
  fi
  
  # Check nginx
  if systemctl is-active --quiet nginx; then
    echo "   ✅ nginx service running"
  else
    echo "   ❌ nginx service not running"
    sudo systemctl status nginx
    exit 1
  fi
EOF

# Check API health endpoint
echo "3. Checking API health endpoint..."
HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$EC2_PUBLIC_IP:8081/health)
if [ "$HEALTH_RESPONSE" = "200" ]; then
  echo "   ✅ Health endpoint responding"
  curl -s http://$EC2_PUBLIC_IP:8081/health | jq .
else
  echo "   ❌ Health endpoint not responding (HTTP $HEALTH_RESPONSE)"
  exit 1
fi

# Check DynamoDB tables
echo "4. Checking DynamoDB tables..."
if aws dynamodb describe-table --table-name $KIRO_QUEUE_TABLE --region $AWS_REGION > /dev/null 2>&1; then
  echo "   ✅ Task queue table exists"
else
  echo "   ❌ Task queue table not found"
  exit 1
fi

if aws dynamodb describe-table --table-name $KIRO_SESSIONS_TABLE --region $AWS_REGION > /dev/null 2>&1; then
  echo "   ✅ Sessions table exists"
else
  echo "   ❌ Sessions table not found"
  exit 1
fi

echo ""
echo "✅ All health checks passed!"
echo "🔗 API URL: http://$EC2_PUBLIC_IP/api/kiro/"
