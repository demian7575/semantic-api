#!/bin/bash
set -e

# Load environment
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

ENVIRONMENT=${1:-production}

echo "🚀 Deploying Kiro API to $ENVIRONMENT..."

# 1. Deploy DynamoDB tables
echo "📊 Creating DynamoDB tables..."
aws cloudformation deploy \
  --template-file infrastructure/dynamodb-tables.yml \
  --stack-name kiro-api-dynamodb \
  --region $AWS_REGION \
  --no-fail-on-empty-changeset

# 2. Build and package
echo "📦 Building application..."
npm install --production

# 3. Deploy to EC2
echo "🚢 Deploying to EC2..."
if [ -z "$EC2_PUBLIC_IP" ]; then
  echo "❌ EC2_PUBLIC_IP not set in .env"
  exit 1
fi

# Copy files to EC2
rsync -avz --exclude 'node_modules' --exclude '.git' \
  -e "ssh -i $EC2_KEY_PATH" \
  ./ ec2-user@$EC2_PUBLIC_IP:/opt/kiro-api/

# Install dependencies on EC2
ssh -i $EC2_KEY_PATH ec2-user@$EC2_PUBLIC_IP << 'EOF'
  cd /opt/kiro-api
  npm install --production
  
  # Restart services
  sudo systemctl restart kiro-api
  sudo systemctl restart nginx
  
  # Wait for services to start
  sleep 5
  
  # Check health
  curl -f http://localhost:8081/health || exit 1
EOF

echo "✅ Deployment complete!"
echo "🔗 API URL: http://$EC2_PUBLIC_IP/api/kiro/"
echo "📊 Health: http://$EC2_PUBLIC_IP/health"
