# Semantic API

Template-based intent-driven API that integrates Kiro CLI with AWS infrastructure.

## 🎯 Current Architecture (2026-02-25)

```
User → S3 Frontpage → API Gateway → Lambda → Dev EC2:9000
                                      ↓
                              Auto-starts if stopped
```

**Components:**
- **Frontend**: S3 static website (http://semantic-api-frontend.s3-website-us-east-1.amazonaws.com)
- **Backend**: Node.js server on Dev EC2 (3.236.230.212:9000)
- **Auto-Start**: Shared Lambda with AIPM (`aipm-ec2-controller`)
- **API Gateway**: https://nger6kll11.execute-api.us-east-1.amazonaws.com

## 🚀 Quick Start

### Access the Frontend
```
http://semantic-api-frontend.s3-website-us-east-1.amazonaws.com
```

The page will automatically start EC2 if stopped and load templates.

### Direct API Access
```bash
# Ensure EC2 is running
curl "https://nger6kll11.execute-api.us-east-1.amazonaws.com/?action=start&env=semantic-api"

# Call API directly
curl "http://3.236.230.212:9000/templates"
curl "http://3.236.230.212:9000/weather?city=Seoul"
```

## 📡 API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/templates` | List all templates |
| GET | `/template/{name}` | Get template content |
| PUT | `/template/{name}` | Create/update template |
| DELETE | `/template/{name}` | Delete template |
| GET | `/weather` | Weather API (example) |
| POST | `/aipm/*` | AIPM integration endpoints |

## 🎨 How It Works

### Request Flow
```
1. User opens S3 frontpage
2. Page calls EC2Manager.ensureRunning('semantic-api')
3. Lambda checks EC2 state
   - If stopped: starts it, waits ~30s
   - If running: returns immediately
4. Page loads templates from http://3.236.230.212:9000
5. User interacts with templates
6. Kiro CLI executes template logic
7. Results returned via callback
```

### Template Execution
```
1. User clicks "Test" on template
2. Frontend sends request to semantic-api server
3. Server spawns Kiro CLI with template content
4. Kiro CLI executes bash commands
5. Kiro CLI posts result to /callback/{taskId}
6. Server returns result to frontend
```

## 📁 Project Structure

```
semantic-api/
├── public/
│   ├── index.html              # Frontend (deployed to S3)
│   └── ec2-manager.js          # EC2 auto-start logic (from AIPM)
├── src/
│   └── semantic-api-server-sync.js  # Main server
├── templates/
│   ├── SEMANTIC_API_GUIDELINES.md
│   ├── GET-weather.md
│   └── POST-*.md
├── scripts/
│   ├── deploy-dev.sh           # Deploy to EC2
│   └── deploy-s3.sh            # Deploy frontend to S3
├── semantic-api.service        # Systemd service
├── README.md                   # This file
└── AUTO-START-SETUP.md         # Auto-start setup guide
```

## 🚢 Deployment

### Deploy Backend to EC2
```bash
./scripts/deploy-dev.sh
```

### Deploy Frontend to S3
```bash
./scripts/deploy-s3.sh
```

### Manual EC2 Deployment
```bash
scp -r . ec2-user@3.236.230.212:~/semantic-api/
ssh ec2-user@3.236.230.212
cd semantic-api
npm install
sudo cp semantic-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable semantic-api
sudo systemctl start semantic-api
```

## 🔧 Configuration

### Environment Variables
- `KIRO_API_PORT`: Server port (default: 8183, currently: 9000)
- `KIRO_CLI_PATH`: Path to kiro-cli binary
- `MAX_CONCURRENT`: Max concurrent Kiro CLI processes (default: 5)

### Lambda Configuration
In `/repo/ebaejun/tools/aws/aipm/lambda/ec2-controller.py`:
```python
INSTANCES = {
    'prod': 'i-09971cca92b9bf3a9',      # AIPM prod
    'dev': 'i-08c78da25af47b3cb',       # AIPM dev
    'semantic-api': 'i-08c78da25af47b3cb'  # Semantic-API (same as dev)
}
```

## 📊 Features

- ✅ **Auto-start EC2** - Starts automatically when accessed
- ✅ **Template management** - Create, edit, delete templates via UI
- ✅ **Kiro CLI integration** - Execute templates with Kiro CLI
- ✅ **Concurrent execution** - Max 5 parallel requests
- ✅ **Zero dependencies** - Pure Node.js server
- ✅ **Hot reload** - Add templates without restart
- ✅ **S3 frontend** - Static website hosting

## 🔍 Monitoring

```bash
# Check EC2 status
curl "https://nger6kll11.execute-api.us-east-1.amazonaws.com/?action=status&env=semantic-api"

# Check service on EC2
ssh ec2-user@3.236.230.212 "sudo systemctl status semantic-api"

# View logs
ssh ec2-user@3.236.230.212 "sudo journalctl -u semantic-api -f"

# Check if port 9000 is listening
ssh ec2-user@3.236.230.212 "sudo netstat -tlnp | grep 9000"
```

## 🆘 Troubleshooting

### Templates not loading
1. Check EC2 is running: `?action=status&env=semantic-api`
2. Check service: `sudo systemctl status semantic-api`
3. Check port: `curl http://3.236.230.212:9000/health`

### Auto-start not working
1. Check Lambda logs: `aws logs tail /aws/lambda/aipm-ec2-controller --follow`
2. Verify Lambda has EC2 permissions
3. Check API Gateway integration

### Frontend errors
1. Open browser console (F12)
2. Check for CORS errors
3. Verify API_BASE URL in index.html

## 📝 Related Documentation

- `AUTO-START-SETUP.md` - Detailed auto-start setup guide
- `/repo/ebaejun/tools/aws/aipm/docs/LAMBDA_AUTO_START_SETUP.md` - AIPM Lambda setup

## 📈 Cost

- **EC2**: ~$0.01/hour when running (t3.small)
- **S3**: ~$0.023/GB storage + $0.09/GB transfer
- **API Gateway**: ~$1.00 per 1M requests
- **Lambda**: ~$0.20 per 1M requests

Auto-stop saves ~$15/month if idle 50% of time.

## 📝 License

MIT


```
┌──────────┐
│  Client  │  (Browser, curl, API client)
└────┬─────┘
     │ HTTP Request (GET/POST)
     │ /weather?city=Seoul
     ▼
┌─────────────────────────────────────────────────────────┐
│         Semantic API Server (Port 8082)                 │
│         semantic-api-server-sync.js                     │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Request Router                                   │ │
│  │  • /health → Health check                         │ │
│  │  • /templates → List templates                    │ │
│  │  • /template/{name} → CRUD operations             │ │
│  │  • /callback/{taskId} → Receive Kiro results      │ │
│  │  • /{endpoint} → Template-based execution         │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Concurrency Control                              │ │
│  │  activeCount: 0-5 | MAX_CONCURRENT: 5             │ │
│  │  pendingRequests: Map<taskId, response>           │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Template Processing                              │ │
│  │  1. Map URL → Template (METHOD-path.md)           │ │
│  │  2. Read template file                            │ │
│  │  3. Inject {{parameters}}                         │ │
│  │  4. Generate taskId                               │ │
│  │  5. Store pending request                         │ │
│  │  6. Spawn Kiro CLI with injected content          │ │
│  └───────────────────────────────────────────────────┘ │
└────────────┬────────────────────────────┬───────────────┘
             │                            │
             │ spawn()                    │ 
             │ stdin: template content    │ 
             ▼                            │
┌──────────────────────────────────────────┼──────────────┐
│   Kiro CLI Process (max 5 concurrent)    │              │
│                                          │              │
│  $ kiro-cli chat \                       │              │
│      --trust-all-tools \                 │              │
│      --no-interactive                    │              │
│                                          │              │
│  ┌────────────────────────────────────┐ │              │
│  │ stdin (from server)                │ │              │
│  │ ─────────────────────────────────  │ │              │
│  │ Fetch weather for Seoul            │ │              │
│  │ RESULT='{"city":"Seoul",...}'      │ │              │
│  │ curl -X POST \                     │ │              │
│  │   http://localhost:8183/callback/\ │ │              │
│  │   task-123 -d "$RESULT"            │ │              │
│  └────────────────────────────────────┘ │              │
│                                          │              │
│  ┌────────────────────────────────────┐ │              │
│  │ Kiro executes:                     │ │              │
│  │ 1. Parse template                  │ │              │
│  │ 2. Execute bash commands           │ │              │
│  │ 3. Run curl POST to callback       │ │              │
│  └────────────────────────────────────┘ │              │
│                                          │              │
│  ┌────────────────────────────────────┐ │              │
│  │ stdout/stderr (logged by server)   │ │              │
│  │ ─────────────────────────────────  │ │              │
│  │ Kiro CLI error: ...                │ │              │
│  └────────────────────────────────────┘ │              │
└──────────────────────────────────────────┼──────────────┘
                                          │
                                          │ HTTP POST
                                          │ (from curl in template)
                                          ▼
                             ┌────────────────────────────┐
                             │  Callback Endpoint         │
                             │  /callback/{taskId}        │
                             │                            │
                             │  Body: {"city":"Seoul"...} │
                             │                            │
                             │  • Match taskId            │
                             │  • Send response to client │
                             │  • Cleanup state           │
                             │  • Timeout: 90s            │
                             └────────────────────────────┘
                                                          │
                                                          ▼
┌─────────────────────────────────────────────────────────┐
│                  templates/*.md                         │
│                                                         │
│  • SEMANTIC_API_GUIDELINES.md (shared baseline)        │
│  • GET-weather.md                                      │
│  • POST-aipm-story-draft.md                            │
│  • POST-aipm-acceptance-test-draft.md                  │
│  • POST-aipm-gwt-analysis.md                           │
│  • POST-aipm-invest-analysis.md                        │
│                                                         │
│  Each template:                                         │
│  - Contains {{parameter}} placeholders                  │
│  - Bash commands to execute                            │
│  - curl callback with {{taskId}}                       │
└─────────────────────────────────────────────────────────┘
```

**No dependencies**: Pure Node.js, no database, no queue

### Request Flow

```
1. Client → POST /aipm/story-draft {"title": "Login"}
2. Server → Check concurrency (activeCount < 5)
3. Server → Map to POST-aipm-story-draft.md
4. Server → Inject parameters, generate taskId
5. Server → Store in pendingRequests, activeCount++
6. Server → Spawn Kiro CLI with template content
7. Kiro CLI → Execute bash commands
8. Kiro CLI → curl POST /callback/{taskId} with result
9. Server → Match taskId, send response to client
10. Server → Cleanup (activeCount--, remove from map)
11. Client ← Receive JSON response
```

### Kiro CLI Interaction Detail

```
Server Process                    Kiro CLI Process
─────────────────────────────────────────────────────────────

spawn('kiro-cli', [
  'chat',
  '--trust-all-tools',
  '--no-interactive'
])
    │
    │ stdin.write()
    ├──────────────────────────────►  stdin
    │                                   │
    │  Injected template content:       │ Kiro reads and
    │  ─────────────────────────────    │ interprets template:
    │  Fetch weather for Seoul          │
    │  RESULT='{"city":"Seoul"}'        │ $ RESULT='{"city":"Seoul"}'
    │  curl -X POST \                   │ $ curl -X POST \
    │    /callback/task-123 \           │     /callback/task-123 \
    │    -d "$RESULT"                   │     -d "$RESULT"
    │                                   │
    │                                   │ stdout (logged)
    │ stderr.on('data')  ◄──────────────┤ stderr (errors)
    │                                   │
    │                                   │
    │                                   │ Executes curl command
    │                                   │ inside template
    │                                   └──────┐
    │                                          │
    │                                          ▼
    │                                   HTTP POST
    │                                   /callback/task-123
    │                                   {"city":"Seoul",...}
    │                                          │
    │ ◄────────────────────────────────────────┘
    │ POST /callback/{taskId}
    │
    │ Match taskId in pendingRequests
    │ Send response to waiting client
    │ activeCount--
    │ pendingRequests.delete(taskId)
    │
    ▼
Response to Client
```

## 🚀 Quick Start

```bash
# Install (no dependencies!)
npm install

# Start server
npm start

# Test
curl "http://localhost:8183/weather?city=Seoul"
```

## 📡 API Usage

### 1. Create endpoint by adding template

File: `templates/GET-weather.md`
```markdown
# Weather Template
Fetch weather for {{city}}
Output JSON only.
```

### 2. Call endpoint (synchronous)

```bash
curl -X GET "http://localhost:8183/weather?city=Seoul"
# Waits and returns: {"city": "Seoul", "temp_c": "5", ...}
```

That's it! No polling, no task IDs, just standard REST API.

## 🔧 How It Works

1. **Request**: `GET /weather?city=Seoul`
2. **Template lookup**: `templates/GET-weather.md`
3. **Parameter injection**: Replace `{{city}}` with `Seoul`, `{{taskId}}` with generated ID
4. **Spawn Kiro CLI**: Pass injected template content via stdin (non-interactive)
5. **Kiro CLI executes**: Interprets template and runs bash commands
6. **Callback**: Kiro CLI's curl command posts result to `/callback/{taskId}`
7. **Response**: Server matches taskId and returns result to client

## 📁 Project Structure

```
semantic-api/
├── src/
│   └── semantic-api-server-sync.js    # Main server (180 lines)
├── templates/
│   ├── SEMANTIC_API_GUIDELINES.md     # Shared guidelines
│   ├── GET-weather.md                 # Weather endpoint
│   ├── GET-aipm-stories.md            # DynamoDB reader
│   ├── POST-aipm-story-draft.md       # Story generator
│   └── ...                            # More templates
├── package.json                       # Zero dependencies
└── semantic-api.service               # Systemd service
```

## 🎨 Template Format

```markdown
# Template Title

**BASELINE**: See templates/SEMANTIC_API_GUIDELINES.md

## ROLE ASSIGNMENT
**YOU ARE**: [Role description]

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: [What you can do]

## Parameters
- `param1`: Description
- `param2`: Description

## Instructions

[Instructions for Kiro CLI]

Output only valid JSON:
```json
{
  "result": "data"
}
```

No explanations. JSON only.
```

## 🔌 Available Endpoints

| Method | Path | Template | Description |
|--------|------|----------|-------------|
| GET | `/weather` | GET-weather.md | Fetch weather data |
| GET | `/aipm/stories` | GET-aipm-stories.md | Read DynamoDB story |
| POST | `/aipm/story-draft` | POST-aipm-story-draft.md | Generate user story |
| POST | `/aipm/acceptance-test-draft` | POST-aipm-acceptance-test-draft.md | Generate acceptance test |
| POST | `/aipm/gwt-analysis` | POST-aipm-gwt-analysis.md | Analyze test quality |
| POST | `/aipm/invest-analysis` | POST-aipm-invest-analysis.md | Analyze story quality |

## 🛠️ Management Endpoints

- `GET /health` - Health check
- `GET /templates` - List all templates
- `GET /template/{name}` - Get template content
- `PUT /template/{name}` - Create/update template
- `DELETE /template/{name}` - Delete template

## 🚢 Deployment

```bash
# Copy to EC2
scp -r . ec2-user@44.222.168.46:~/semantic-api/

# SSH to EC2
ssh ec2-user@44.222.168.46

# Setup systemd
sudo cp semantic-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable semantic-api
sudo systemctl start semantic-api

# Check status
sudo systemctl status semantic-api
curl http://localhost:8183/health
```

## 📊 Features

- ✅ **Zero dependencies** - Pure Node.js
- ✅ **Synchronous API** - Standard REST pattern
- ✅ **Concurrent execution** - Max 5 parallel requests
- ✅ **Template-based** - Add endpoints by adding markdown files
- ✅ **Parameter injection** - `{{param}}` replaced automatically
- ✅ **Error handling** - Returns error details on failure
- ✅ **No database** - Stateless design
- ✅ **Hot reload** - Add templates without restart

## 🔍 Monitoring

```bash
# Check health
curl http://localhost:8183/health

# View logs
sudo journalctl -u semantic-api -f

# Check active requests
curl http://localhost:8183/health | jq '.activeRequests'
```

## 🧪 Testing

```bash
# Run test script
./test-sync-server.sh

# Manual test
curl -X GET "http://localhost:8183/weather?city=Tokyo"
# Returns result immediately
```

## 💡 Design Principles

1. **Simplicity**: Standard REST API pattern
2. **Transparency**: URL → Template mapping is obvious
3. **Flexibility**: Add endpoints by adding files
4. **Reliability**: Concurrent limit prevents overload
5. **Observability**: Health endpoint shows system state

## 🔒 Security Notes

- Run as non-root user (ec2-user)
- Kiro CLI executes with user permissions
- No authentication (add nginx + auth if needed)
- Templates can execute bash commands (trust your templates!)

## 📈 Performance

- **Latency**: ~2-10s per request (Kiro CLI execution time)
- **Throughput**: 5 concurrent requests max
- **Memory**: ~100MB base + ~50MB per active Kiro CLI
- **CPU**: Depends on Kiro CLI workload

## 🆚 Architecture Evolution

| Version | Pattern | Complexity |
|---------|---------|------------|
| v1 (Original) | Server + DynamoDB + Worker + Callback | High |
| v2 (Async) | Server + Queue + TaskId polling | Medium |
| v3 (Sync) | Server → Kiro CLI → Response | **Minimal** |

## 📝 Example Request/Response

```bash
# Request
curl -X POST http://localhost:8183/aipm/invest-analysis \
  -H "Content-Type: application/json" \
  -d '{
    "storyId": 123,
    "title": "User login",
    "description": "Implement authentication",
    "asA": "user",
    "iWant": "to login",
    "soThat": "I can access my account"
  }'

# Response (immediate)
{
  "storyId": 123,
  "summary": "Story follows INVEST principles well",
  "score": 85,
  "warnings": [],
  "strengths": ["Clear value", "Testable"],
  "source": "ai",
  "model": "kiro-cli"
}
```

## 📝 License

MIT

## 🆘 Support

- Issues: Create GitHub issue
- Logs: `sudo journalctl -u semantic-api -f`
- Health: `curl http://localhost:8183/health`
