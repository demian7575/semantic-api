# Kiro API Architecture

## Overview

This document describes the architecture of the Kiro API integration system, designed to provide a production-ready REST API for Amazon Q (Kiro CLI) code generation capabilities.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                             │
│  (Web Browser, Mobile App, CLI Tool, CI/CD Pipeline)            │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    S3 Static Frontend (Optional)                 │
│  - React/Vue/Vanilla JS application                             │
│  - Hosted on S3 with CloudFront                                 │
│  - Communicates with backend via REST API                       │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Application Load Balancer                     │
│  - SSL/TLS termination                                          │
│  - Health checks                                                │
│  - Auto-scaling trigger                                         │
└────────────┬───────────────────────────┬────────────────────────┘
             │                           │
             ▼                           ▼
┌────────────────────────┐    ┌──────────────────────────────────┐
│  nginx (Port 80/443)   │    │  nginx (Port 80/443)             │
│  Reverse Proxy         │    │  Reverse Proxy                   │
└────────┬───────────────┘    └──────────────┬───────────────────┘
         │                                   │
         ├─────────────┬─────────────────────┤
         ▼             ▼                     ▼
┌─────────────┐ ┌──────────────┐  ┌──────────────────────────────┐
│ Kiro API    │ │ Backend API  │  │ Additional Services          │
│ Port 8081   │ │ Port 4000    │  │ (Monitoring, Logging, etc.)  │
└──────┬──────┘ └──────┬───────┘  └──────────────────────────────┘
       │               │
       └───────┬───────┘
               ▼
    ┌──────────────────────┐
    │     DynamoDB         │
    │  - Task Queue        │
    │  - Session State     │
    │  - Results Cache     │
    └──────────────────────┘
```

## Component Details

### 1. Kiro API Server (Port 8081)

**Purpose**: Manages Kiro CLI sessions and processes code generation requests.

**Key Features**:
- Session pooling (max 5 concurrent sessions)
- Task queue management
- Automatic session cleanup
- Health monitoring
- Graceful error handling

**Technology Stack**:
- Node.js 18+
- Native HTTP server (no framework overhead)
- AWS SDK v3 (DynamoDB)
- Child process management for Kiro CLI

**Endpoints**:
- `POST /api/chat` - Submit code generation request
- `GET /api/task/:taskId` - Get task status and result
- `GET /health` - Health check endpoint

### 2. Backend API (Port 4000)

**Purpose**: Handles business logic, authentication, and data operations.

**Key Features**:
- User authentication and authorization
- Data validation
- Business logic processing
- Integration with other services

**Technology Stack**:
- Node.js 18+
- Express.js or native HTTP
- AWS SDK v3
- JWT for authentication

### 3. nginx Reverse Proxy

**Purpose**: Routes traffic, handles SSL, and provides load balancing.

**Configuration**:
```nginx
upstream kiro_api {
    server localhost:8081;
    keepalive 32;
}

upstream backend_api {
    server localhost:4000;
    keepalive 32;
}

server {
    listen 80;
    
    location /api/kiro/ {
        proxy_pass http://kiro_api/;
        proxy_read_timeout 300s;
    }
    
    location /api/ {
        proxy_pass http://backend_api/;
    }
}
```

### 4. DynamoDB Tables

#### Task Queue Table
```
Table: kiro-task-queue
Partition Key: taskId (String)
Sort Key: createdAt (Number)

Attributes:
- taskId: Unique task identifier
- status: pending | processing | completed | failed
- createdAt: Timestamp
- prompt: User's code generation request
- result: Generated code (when completed)
- sessionId: Associated Kiro session
- error: Error message (if failed)
- metadata: Additional task information

GSI: status-createdAt-index
- Partition Key: status
- Sort Key: createdAt
- Purpose: Query tasks by status
```

#### Sessions Table
```
Table: kiro-sessions
Partition Key: sessionId (String)

Attributes:
- sessionId: Unique session identifier
- status: active | idle | closed
- lastActivity: Timestamp
- processId: Kiro CLI process ID
- tasksProcessed: Number of tasks handled
- metadata: Additional session information
```

## Data Flow

### 1. Task Submission Flow

```
Client → nginx → Kiro API → DynamoDB
  ↓
  1. Client sends POST /api/chat with message
  2. nginx routes to Kiro API (port 8081)
  3. Kiro API creates task in DynamoDB
  4. Task added to in-memory queue
  5. Returns taskId to client
```

### 2. Task Processing Flow

```
Queue Processor → Session Pool → Kiro CLI → DynamoDB
  ↓
  1. Queue processor picks pending task
  2. Assigns task to available session
  3. Sends message to Kiro CLI process
  4. Waits for Kiro response (max 5 minutes)
  5. Updates task status in DynamoDB
  6. Marks session as idle
```

### 3. Result Retrieval Flow

```
Client → nginx → Kiro API → DynamoDB → Client
  ↓
  1. Client polls GET /api/task/:taskId
  2. nginx routes to Kiro API
  3. Kiro API queries DynamoDB
  4. Returns task status and result
```

## Session Management

### Session Lifecycle

```
Created → Active → Idle → Closed
   ↓        ↓       ↓       ↓
  Start   Process  Wait   Cleanup
```

**States**:
- **Created**: Session object initialized
- **Active**: Kiro CLI process running, handling task
- **Idle**: Process running, waiting for next task
- **Closed**: Process terminated, resources released

**Cleanup Policy**:
- Idle sessions closed after 10 minutes of inactivity
- Failed sessions immediately closed and restarted
- Maximum 5 concurrent sessions (configurable)

## Scaling Strategy

### Vertical Scaling
- Increase EC2 instance size (t3.small → t3.medium → t3.large)
- Increase max sessions per instance
- Add more memory for larger code generation tasks

### Horizontal Scaling
- Deploy multiple EC2 instances
- Use Application Load Balancer
- Shared DynamoDB for task queue
- Session affinity not required (stateless design)

### Auto-Scaling Configuration
```yaml
MinInstances: 1
MaxInstances: 5
TargetCPU: 70%
TargetMemory: 80%
ScaleUpCooldown: 300s
ScaleDownCooldown: 600s
```

## High Availability

### Multi-AZ Deployment
```
┌─────────────────────────────────────────┐
│         Application Load Balancer        │
│              (Multi-AZ)                  │
└────────┬──────────────────┬──────────────┘
         │                  │
    ┌────▼────┐        ┌────▼────┐
    │  AZ-1   │        │  AZ-2   │
    │  EC2    │        │  EC2    │
    │ Instance│        │ Instance│
    └────┬────┘        └────┬────┘
         │                  │
         └────────┬─────────┘
                  ▼
         ┌────────────────┐
         │   DynamoDB     │
         │   (Global)     │
         └────────────────┘
```

### Disaster Recovery
- **RTO**: 15 minutes (time to launch new instance)
- **RPO**: 0 (DynamoDB continuous backup)
- **Backup Strategy**: DynamoDB point-in-time recovery enabled
- **Failover**: Automatic via ALB health checks

## Security

### Network Security
```
Internet → ALB (HTTPS) → EC2 (Private Subnet) → DynamoDB (VPC Endpoint)
```

**Security Groups**:
- ALB: Allow 443 from 0.0.0.0/0
- EC2: Allow 80, 8081, 4000 from ALB only
- DynamoDB: VPC endpoint, no public access

### Application Security
- **Authentication**: JWT tokens or API keys
- **Authorization**: Role-based access control
- **Encryption**: TLS 1.2+ for all traffic
- **Secrets**: AWS Secrets Manager for credentials
- **IAM**: Least privilege roles for EC2 instances

### Data Security
- **DynamoDB**: Encryption at rest enabled
- **S3**: Server-side encryption (SSE-S3)
- **Logs**: CloudWatch Logs with encryption
- **Backups**: Encrypted snapshots

## Monitoring & Observability

### Metrics (CloudWatch)
- **API Metrics**:
  - Request count
  - Response time (p50, p95, p99)
  - Error rate
  - Active sessions
  - Queue length

- **System Metrics**:
  - CPU utilization
  - Memory usage
  - Disk I/O
  - Network throughput

- **Business Metrics**:
  - Tasks completed per hour
  - Average task duration
  - Success rate
  - User activity

### Logging
```
Application Logs → CloudWatch Logs → S3 (Archive)
                        ↓
                   Log Insights
                        ↓
                    Alarms
```

**Log Levels**:
- ERROR: System errors, failed tasks
- WARN: Retries, slow responses
- INFO: Task lifecycle events
- DEBUG: Detailed execution traces

### Alarms
- High error rate (> 5%)
- High queue length (> 100 tasks)
- Low session availability (< 2 active)
- High response time (> 30s p95)
- EC2 instance health check failures

## Cost Optimization

### Current Costs (Estimated)
```
EC2 (t3.small, 24/7):     $15/month
DynamoDB (on-demand):     $5/month
Data Transfer:            $2/month
CloudWatch:               $3/month
S3 (frontend):            $1/month
─────────────────────────────────
Total:                    ~$26/month
```

### Optimization Strategies
1. **Reserved Instances**: Save 30-40% on EC2
2. **Spot Instances**: Save 70% for non-critical workloads
3. **DynamoDB Reserved Capacity**: Save 50% for predictable load
4. **S3 Lifecycle Policies**: Archive old logs to Glacier
5. **CloudWatch Log Retention**: Reduce to 7 days for debug logs

## Performance Characteristics

### Latency
- **Health Check**: < 10ms
- **Task Submission**: < 100ms
- **Task Processing**: 5-60 seconds (depends on complexity)
- **Result Retrieval**: < 50ms

### Throughput
- **Single Instance**: 5 concurrent tasks
- **With 5 Instances**: 25 concurrent tasks
- **Tasks per Hour**: ~300-600 (depends on task complexity)

### Limits
- **Max Task Size**: 400KB (DynamoDB item limit)
- **Max Result Size**: 400KB (DynamoDB item limit)
- **Max Session Duration**: 10 minutes idle timeout
- **Max Task Duration**: 5 minutes (configurable)

## Deployment Architecture

### CI/CD Pipeline
```
GitHub → GitHub Actions → Build → Test → Deploy → Verify
   ↓          ↓            ↓       ↓       ↓        ↓
 Code      Checkout     npm      Unit    rsync   Health
 Push      Code         build    Tests   to EC2   Check
```

### Deployment Strategy
- **Blue-Green**: Zero-downtime deployments
- **Canary**: Gradual rollout to 10% → 50% → 100%
- **Rollback**: Automatic on health check failure

### Infrastructure as Code
- **DynamoDB**: CloudFormation templates
- **EC2**: Launch templates with user data
- **nginx**: Configuration management
- **Services**: systemd unit files

## Future Enhancements

### Short Term (1-3 months)
- [ ] WebSocket support for real-time updates
- [ ] Task priority queue
- [ ] Rate limiting per user
- [ ] Caching layer (Redis)

### Medium Term (3-6 months)
- [ ] Multi-region deployment
- [ ] GraphQL API
- [ ] Advanced analytics dashboard
- [ ] A/B testing framework

### Long Term (6-12 months)
- [ ] Kubernetes migration
- [ ] Serverless option (Lambda + SQS)
- [ ] Machine learning for task optimization
- [ ] Self-service developer portal

## References

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [Node.js Performance Best Practices](https://nodejs.org/en/docs/guides/simple-profiling/)
- [nginx Tuning Guide](https://www.nginx.com/blog/tuning-nginx/)
