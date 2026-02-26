# Auto-Start Setup Guide

## Overview

Semantic API uses AIPM's Lambda function for EC2 auto-start. When users access the S3 frontpage, it automatically starts the EC2 instance if stopped.

## Current Setup (2026-02-26)

### Architecture
```
User → S3 Frontpage → API Gateway → Lambda → Dev EC2:9000
         ↓
    Auto-starts if stopped
    Inline Input/Response UI
```

### Components
- **S3 Frontpage**: http://semantic-api-frontend.s3-website-us-east-1.amazonaws.com
- **API Gateway**: https://nger6kll11.execute-api.us-east-1.amazonaws.com
- **Lambda**: `aipm-ec2-controller` (Python, shared with AIPM)
- **EC2**: Dev instance (port 9000)

## How It Works

1. User opens S3 frontpage
2. Page loads `ec2-manager.js` (copied from AIPM)
3. Calls `EC2Manager.ensureRunning('semantic-api')`
4. Lambda checks EC2 state via `?action=status&env=semantic-api`
5. If stopped: Lambda starts EC2, waits ~30s
6. If running: Returns immediately with current IP
7. Page loads templates from `http://<EC2-IP>:9000`
8. User clicks template → Test → Edit Input → Execute
9. Response appears below Input (both visible)

## Lambda Configuration

The Lambda function (`aipm-ec2-controller`) handles three environments:

```python
INSTANCES = {
    'prod': 'i-09971cca92b9bf3a9',      # AIPM prod
    'dev': 'i-08c78da25af47b3cb',       # AIPM dev
    'semantic-api': 'i-08c78da25af47b3cb'  # Semantic-API (same as dev)
}
```

## Frontend Integration

The frontpage uses AIPM's `ec2-manager.js`:

```javascript
// In index.html
// API_BASE is dynamically set from Lambda status response
const status = await fetch(`${EC2_CONTROL_API}?action=status&env=semantic-api`).then(r => r.json());
API_BASE = `http://${status.publicIp}:9000`;

async function initApp() {
    await EC2Manager.ensureRunning('semantic-api');
    loadTemplates();
}
```

## Testing

### Test Auto-Start
```bash
# Stop EC2
curl "https://nger6kll11.execute-api.us-east-1.amazonaws.com/?action=stop&env=semantic-api"

# Open frontpage - should auto-start
open http://semantic-api-frontend.s3-website-us-east-1.amazonaws.com
```

### Test Lambda Directly
```bash
# Check status
curl "https://nger6kll11.execute-api.us-east-1.amazonaws.com/?action=status&env=semantic-api"

# Start EC2
curl "https://nger6kll11.execute-api.us-east-1.amazonaws.com/?action=start&env=semantic-api"
```

## Deployment

### Deploy Lambda Changes
```bash
cd /repo/ebaejun/tools/aws/aipm/lambda
python3 -c "import zipfile; zipfile.ZipFile('ec2-controller.zip', 'w').write('ec2-controller.py', 'lambda_function.py')"
aws lambda update-function-code \
  --function-name aipm-ec2-controller \
  --zip-file fileb://ec2-controller.zip \
  --region us-east-1
```

### Deploy Frontend
```bash
cd /repo/ebaejun/tools/aws/semantic-api
./scripts/deploy-s3.sh
```

## Monitoring

### Lambda Logs
```bash
aws logs tail /aws/lambda/aipm-ec2-controller --follow --region us-east-1
```

### EC2 Status
```bash
curl "https://nger6kll11.execute-api.us-east-1.amazonaws.com/?action=status&env=semantic-api" | jq
```

## Cost

- **Lambda**: ~$0.20 per 1M requests
- **API Gateway**: ~$1.00 per 1M requests
- **EC2 auto-stop**: Saves ~$15/month (if idle 50% of time)

Net savings: ~$13-14/month

## Troubleshooting

### Templates not loading
1. Check browser console (F12) for errors
2. Verify EC2 is running: `?action=status&env=semantic-api`
3. Test direct access: `curl http://<EC2-IP>:9000/templates`

### Auto-start fails
1. Check Lambda logs for errors
2. Verify Lambda has EC2 permissions
3. Check API Gateway integration

### First request timeout
- Normal - EC2 takes ~30-40s to start
- Subsequent requests are instant
