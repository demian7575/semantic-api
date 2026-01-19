# Quick Start Guide

Get your Kiro API up and running in 15 minutes.

## Prerequisites

- AWS account with admin access
- AWS CLI configured (`aws configure`)
- Node.js 18+ installed
- SSH key pair for EC2 access
- Kiro CLI installed and authenticated

## Step 1: Clone and Setup (2 minutes)

```bash
# Clone repository
git clone <your-repo-url>
cd kiro-api-project

# Install dependencies
npm install

# Copy environment template
cp .env.example .env
```

## Step 2: Configure Environment (3 minutes)

Edit `.env` file:

```bash
# AWS Configuration
AWS_REGION=us-east-1
AWS_PROFILE=default

# DynamoDB Tables
KIRO_QUEUE_TABLE=kiro-task-queue
KIRO_SESSIONS_TABLE=kiro-sessions

# API Configuration
KIRO_API_PORT=8081
BACKEND_API_PORT=4000
NODE_ENV=production

# Kiro CLI Configuration
KIRO_MAX_SESSIONS=5

# EC2 Configuration (fill these in after launching EC2)
EC2_INSTANCE_ID=
EC2_PUBLIC_IP=
EC2_KEY_PATH=~/.ssh/your-key.pem
```

## Step 3: Create DynamoDB Tables (2 minutes)

```bash
# Deploy DynamoDB tables
aws cloudformation deploy \
  --template-file infrastructure/dynamodb-tables.yml \
  --stack-name kiro-api-dynamodb \
  --region us-east-1

# Verify tables created
aws dynamodb list-tables --region us-east-1
```

Expected output:
```json
{
  "TableNames": [
    "kiro-task-queue",
    "kiro-sessions"
  ]
}
```

## Step 4: Launch EC2 Instance (3 minutes)

### Option A: AWS Console

1. Go to EC2 Console
2. Click "Launch Instance"
3. Choose Amazon Linux 2023
4. Select t3.small instance type
5. Create or select key pair
6. Configure security group:
   - Allow SSH (22) from your IP
   - Allow HTTP (80) from anywhere
   - Allow Custom TCP (8081) from anywhere
7. Launch instance
8. Note the public IP address

### Option B: AWS CLI

```bash
# Create security group
aws ec2 create-security-group \
  --group-name kiro-api-sg \
  --description "Kiro API security group"

# Add rules
aws ec2 authorize-security-group-ingress \
  --group-name kiro-api-sg \
  --protocol tcp --port 22 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name kiro-api-sg \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name kiro-api-sg \
  --protocol tcp --port 8081 --cidr 0.0.0.0/0

# Launch instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.small \
  --key-name your-key-name \
  --security-groups kiro-api-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=kiro-api-server}]'
```

Update `.env` with EC2 details:
```bash
EC2_INSTANCE_ID=i-xxxxxxxxx
EC2_PUBLIC_IP=xx.xx.xx.xx
EC2_KEY_PATH=~/.ssh/your-key.pem
```

## Step 5: Setup EC2 Instance (3 minutes)

```bash
# SSH into EC2
ssh -i ~/.ssh/your-key.pem ec2-user@<EC2_PUBLIC_IP>

# Run setup script
curl -fsSL https://raw.githubusercontent.com/your-repo/main/infrastructure/ec2-setup.sh | bash

# Or manually:
sudo yum update -y
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs nginx git
```

## Step 6: Deploy Application (2 minutes)

From your local machine:

```bash
# Deploy to EC2
./scripts/deploy.sh

# This will:
# 1. Build the application
# 2. Copy files to EC2
# 3. Install dependencies
# 4. Restart services
# 5. Run health checks
```

## Step 7: Verify Deployment (1 minute)

```bash
# Run health check
./scripts/health-check.sh

# Or manually:
curl http://<EC2_PUBLIC_IP>:8081/health
```

Expected output:
```json
{
  "status": "healthy",
  "activeSessions": 0,
  "queueLength": 0,
  "uptime": 123
}
```

## Step 8: Test API (1 minute)

```bash
# Submit a task
curl -X POST http://<EC2_PUBLIC_IP>:8081/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Create a hello world function in Python"}'

# Response:
# {"taskId":"task-1234567890-abc123","status":"pending"}

# Check task status
curl http://<EC2_PUBLIC_IP>:8081/api/task/task-1234567890-abc123

# Response:
# {"taskId":"task-1234567890-abc123","status":"completed","result":"def hello_world():\n    print('Hello, World!')"}
```

## Troubleshooting

### Service Not Starting

```bash
# SSH into EC2
ssh -i ~/.ssh/your-key.pem ec2-user@<EC2_PUBLIC_IP>

# Check service status
sudo systemctl status kiro-api

# View logs
sudo journalctl -u kiro-api -n 50

# Restart service
sudo systemctl restart kiro-api
```

### Health Check Failing

```bash
# Check if port is open
curl http://<EC2_PUBLIC_IP>:8081/health

# Check security group
aws ec2 describe-security-groups --group-names kiro-api-sg

# Check nginx
sudo systemctl status nginx
sudo nginx -t
```

### DynamoDB Access Issues

```bash
# Check IAM role attached to EC2
aws ec2 describe-instances --instance-ids <EC2_INSTANCE_ID> \
  --query 'Reservations[0].Instances[0].IamInstanceProfile'

# If no role, create and attach one:
aws iam create-role --role-name kiro-api-role \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy --role-name kiro-api-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess

aws ec2 associate-iam-instance-profile \
  --instance-id <EC2_INSTANCE_ID> \
  --iam-instance-profile Name=kiro-api-role
```

## Next Steps

1. **Setup SSL**: Configure HTTPS with Let's Encrypt
2. **Add Monitoring**: Setup CloudWatch alarms
3. **Configure Backups**: Enable DynamoDB point-in-time recovery
4. **Setup CI/CD**: Automate deployments with GitHub Actions
5. **Add Authentication**: Implement JWT or API key authentication

## Common Commands

```bash
# Deploy
./scripts/deploy.sh

# Health check
./scripts/health-check.sh

# View logs
ssh -i ~/.ssh/your-key.pem ec2-user@<EC2_PUBLIC_IP>
sudo journalctl -u kiro-api -f

# Restart service
ssh -i ~/.ssh/your-key.pem ec2-user@<EC2_PUBLIC_IP>
sudo systemctl restart kiro-api

# Check DynamoDB
aws dynamodb scan --table-name kiro-task-queue --max-items 10
```

## Support

- Documentation: [README.md](README.md)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Issues: [GitHub Issues](https://github.com/your-repo/issues)

## Success Checklist

- [ ] DynamoDB tables created
- [ ] EC2 instance launched and accessible
- [ ] Application deployed
- [ ] Health check passing
- [ ] Test API call successful
- [ ] Logs accessible
- [ ] Monitoring configured

Congratulations! Your Kiro API is now running. 🎉
