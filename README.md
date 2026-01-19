# Semantic API

Template-based intent-driven API that integrates Kiro CLI with AWS infrastructure.

## 🎯 Project Focus

Ultra-generic HTTP server where URLs map directly to markdown template files. Each template defines the intent, constraints, and instructions for Kiro CLI to execute.

**Architecture**: HTTP method + URL path → Template file → Kiro CLI → Generated code

**Deployment:**
- **Development EC2**: 44.222.168.46:8082
- **Endpoint**: http://44.222.168.46:8082

**Core Components:**
- **Template-Based Routing** - URL paths map to markdown files
- **Semantic API Server** - Minimal HTTP server (130 lines)
- **DynamoDB** - Task queue and state management
- **Kiro CLI Integration** - Direct template passing

**Available Templates:**
- `POST-api-users` - Create user endpoint
- `GET-api-users` - List users endpoint  
- `GET-aipm-stories` - Read AIPM user stories from DynamoDB

See [TEMPLATES.md](TEMPLATES.md) for complete template reference.

## 🚀 Quick Deploy

Deploy to development EC2:
```bash
./scripts/deploy-dev.sh
```

Deployment target:
- EC2: 44.222.168.46
- Port: 8082
- Process manager: PM2
- Health check: http://44.222.168.46:8082/health

## 💻 Local Development

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        S3 Static Frontend                    │
│              (React/Vue/Vanilla JS Application)              │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      nginx (Port 80/443)                     │
│                    Reverse Proxy + SSL                       │
└────────────┬────────────────────────────┬────────────────────┘
             │                            │
             ▼                            ▼
┌────────────────────────┐    ┌──────────────────────────────┐
│   Kiro API (Port 8081) │    │  Backend API (Port 4000)     │
│   - Chat sessions      │    │  - Business logic            │
│   - Code generation    │    │  - Data operations           │
│   - Task management    │    │  - Authentication            │
└────────────┬───────────┘    └──────────────┬───────────────┘
             │                               │
             └───────────────┬───────────────┘
                             ▼
                  ┌──────────────────────┐
                  │      DynamoDB        │
                  │  - Task queue        │
                  │  - Session state     │
                  │  - Results cache     │
                  └──────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- AWS Account with credentials configured
- Node.js 18+
- EC2 instance (t3.small or larger)
- Kiro CLI installed and authenticated

### 1. Deploy Infrastructure

```bash
# Clone and setup
git clone <repository>
cd kiro-api-project

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your AWS credentials and settings

# Deploy to AWS
./scripts/deploy.sh
```

### 2. Start Services

```bash
# On EC2 instance
sudo systemctl start kiro-api
sudo systemctl start nginx
sudo systemctl enable kiro-api nginx
```

### 3. Verify Deployment

```bash
# Health check
curl http://your-ec2-ip:8081/health

# Test Kiro API
curl -X POST http://your-ec2-ip:8081/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello Kiro"}'
```

## 📁 Project Structure

```
kiro-api-project/
├── src/
│   ├── kiro-api-server.js      # Main Kiro API server
│   ├── backend-api.js           # Business logic API
│   └── lib/
│       ├── dynamodb.js          # DynamoDB client
│       ├── kiro-session.js      # Kiro CLI wrapper
│       └── queue-processor.js   # Task queue handler
├── infrastructure/
│   ├── ec2-setup.sh             # EC2 instance setup
│   ├── dynamodb-tables.yml      # DynamoDB table definitions
│   └── nginx.conf               # nginx configuration
├── scripts/
│   ├── deploy.sh                # Deployment script
│   ├── health-check.sh          # Service health checks
│   └── rollback.sh              # Rollback script
├── systemd/
│   ├── kiro-api.service         # Kiro API systemd unit
│   └── backend-api.service      # Backend API systemd unit
├── tests/
│   ├── api.test.js              # API integration tests
│   └── kiro.test.js             # Kiro CLI tests
├── .env.example                 # Environment template
├── package.json
└── README.md
```

## 🔧 Configuration

### Environment Variables

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

# Kiro CLI
KIRO_TIMEOUT=300000
KIRO_MAX_SESSIONS=5
```

### nginx Configuration

```nginx
upstream kiro_api {
    server localhost:8081;
}

upstream backend_api {
    server localhost:4000;
}

server {
    listen 80;
    server_name your-domain.com;

    location /api/kiro/ {
        proxy_pass http://kiro_api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api/ {
        proxy_pass http://backend_api/;
    }
}
```

## 📊 DynamoDB Schema

### Task Queue Table

```javascript
{
  taskId: "uuid",              // Partition key
  status: "pending|processing|completed|failed",
  createdAt: 1234567890,       // Sort key
  prompt: "User request",
  result: "Generated code",
  sessionId: "kiro-session-id",
  metadata: {
    userId: "user-123",
    priority: 1
  }
}
```

### Sessions Table

```javascript
{
  sessionId: "uuid",           // Partition key
  status: "active|idle|closed",
  lastActivity: 1234567890,
  processId: 12345,
  metadata: {
    startedAt: 1234567890,
    tasksProcessed: 10
  }
}
```

## 🔌 API Reference

### Kiro API Endpoints

#### POST /api/generate
Generate code using a template.

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-function",
    "parameters": {
      "name": "calculateSum",
      "description": "sum an array of numbers",
      "language": "javascript"
    }
  }'
```

Response:
```json
{
  "taskId": "uuid",
  "status": "pending",
  "templateId": "create-function"
}
```

#### GET /api/templates
List all available templates.

```bash
curl http://localhost:8081/api/templates
```

Response:
```json
{
  "templates": ["create-api", "create-function", "add-tests", "refactor-code", "fix-bug", "add-documentation"]
}
```

#### GET /api/templates/:templateId
Get template details and parameters.

```bash
curl http://localhost:8081/api/templates/create-function
```

Response:
```json
{
  "id": "create-function",
  "name": "Create Function",
  "description": "Generate a function with specified behavior",
  "parameters": [
    {
      "name": "name",
      "type": "string",
      "required": true,
      "description": "Function name"
    }
  ]
}
```

#### GET /api/task/:taskId
Get task status and result.

```bash
curl http://localhost:8081/api/task/uuid
```

Response:
```json
{
  "taskId": "uuid",
  "status": "completed",
  "result": "Generated code here",
  "completedAt": 1234567890
}
```

#### GET /health
Health check endpoint.

```bash
curl http://localhost:8081/health
```

Response:
```json
{
  "status": "healthy",
  "activeSessions": 2,
  "queueLength": 5,
  "uptime": 3600
}
```

## 🧪 Testing

```bash
# Run all tests
npm test

# Run specific test suite
npm test -- api.test.js

# Run with coverage
npm run test:coverage
```

## 📈 Monitoring

### Health Checks

```bash
# Check all services
./scripts/health-check.sh

# Check specific service
systemctl status kiro-api
journalctl -u kiro-api -f
```

### Metrics

- **API Response Time**: CloudWatch custom metrics
- **Queue Length**: DynamoDB item count
- **Session Count**: Active Kiro processes
- **Error Rate**: Failed tasks / total tasks

## 🔒 Security

- **API Authentication**: JWT tokens or API keys
- **EC2 Security Groups**: Restrict inbound traffic
- **IAM Roles**: Least privilege access
- **Secrets Management**: AWS Secrets Manager
- **HTTPS**: SSL/TLS via nginx or ALB

## 🚢 Deployment

### Production Deployment

```bash
# Deploy to production
./scripts/deploy.sh --env production

# Verify deployment
./scripts/health-check.sh --env production

# Monitor logs
ssh ec2-user@your-ec2-ip
sudo journalctl -u kiro-api -f
```

### Rollback

```bash
# Rollback to previous version
./scripts/rollback.sh --version previous
```

## 🐛 Troubleshooting

### Kiro API Not Responding

```bash
# Check service status
sudo systemctl status kiro-api

# Check logs
sudo journalctl -u kiro-api -n 100

# Restart service
sudo systemctl restart kiro-api
```

### High Queue Length

```bash
# Check queue size
aws dynamodb scan --table-name kiro-task-queue \
  --filter-expression "status = :status" \
  --expression-attribute-values '{":status":{"S":"pending"}}'

# Scale up sessions
# Edit /etc/systemd/system/kiro-api.service
# Set KIRO_MAX_SESSIONS=10
sudo systemctl daemon-reload
sudo systemctl restart kiro-api
```

## 📚 Resources

- [Kiro CLI Documentation](https://docs.aws.amazon.com/amazonq/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [nginx Documentation](https://nginx.org/en/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests
5. Commit (`git commit -m 'Add amazing feature'`)
6. Push (`git push origin feature/amazing-feature`)
7. Open a Pull Request

See [GITHUB_SETUP.md](GITHUB_SETUP.md) for GitHub configuration.

## 📄 License

MIT License - See LICENSE file for details

## 🆘 Support

- GitHub Issues: [Create an issue](https://github.com/your-repo/issues)
- Email: support@your-domain.com
- Slack: #kiro-api-support
