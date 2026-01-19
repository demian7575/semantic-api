# Testing Guide

## Quick Test

```bash
# 1. Start server
npm start

# 2. Run tests (in another terminal)
./scripts/test-api.sh
```

## Manual Tests

### Test 1: Health Check
```bash
curl http://localhost:8081/health
```

Expected:
```json
{
  "status": "healthy",
  "activeSessions": 0,
  "queueLength": 0
}
```

### Test 2: Create User
```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }'
```

Expected:
```json
{
  "taskId": "task-1234567890-abc",
  "status": "pending"
}
```

Maps to: `templates/POST-api-users.md`

### Test 3: Get Users
```bash
curl "http://localhost:8081/api/users?limit=10&offset=0"
```

Expected:
```json
{
  "taskId": "task-1234567890-xyz",
  "status": "pending"
}
```

Maps to: `templates/GET-api-users.md`

### Test 4: Check Task Result
```bash
curl http://localhost:8081/task/task-1234567890-abc
```

Expected:
```json
{
  "taskId": "task-1234567890-abc",
  "status": "completed",
  "result": "...Kiro CLI output...",
  "createdAt": 1737270000000,
  "completedAt": 1737270005000
}
```

## Template Mapping Tests

| Request | Template File | Status |
|---------|--------------|--------|
| `POST /api/users` | `templates/POST-api-users.md` | ✅ Created |
| `GET /api/users` | `templates/GET-api-users.md` | ✅ Created |
| `PUT /api/users/123` | `templates/PUT-api-users-123.md` | ⚠️ Not created |
| `DELETE /api/products` | `templates/DELETE-api-products.md` | ⚠️ Not created |

## Test Results

### Expected Behavior

1. **Health Check** → Returns 200 with status
2. **POST /api/users** → Returns 202 with taskId
3. **GET /api/users** → Returns 202 with taskId
4. **GET /task/:id** → Returns task status and result
5. **Invalid endpoint** → Returns 202 (Kiro CLI handles missing template)

### Kiro CLI Processing

When Kiro CLI receives:
```json
{
  "template": "templates/POST-api-users.md",
  "parameters": {
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }
}
```

It should:
1. Load `templates/POST-api-users.md`
2. Substitute `{{name}}`, `{{email}}`, `{{age}}`
3. Read role, constraints, intent, instructions
4. Generate output per expected schema
5. Return result

## Automated Test Script

The test script (`scripts/test-api.sh`) performs:

1. ✅ Health check
2. ✅ Create user (POST /api/users)
3. ✅ Get users (GET /api/users)
4. ✅ Check task results
5. ✅ Test invalid endpoint
6. ✅ Test non-existent task

## Verification Checklist

- [ ] Server starts without errors
- [ ] Health endpoint returns 200
- [ ] POST /api/users creates task
- [ ] GET /api/users creates task
- [ ] Task IDs are returned
- [ ] Task status can be retrieved
- [ ] Template files are correctly mapped
- [ ] Parameters are passed to Kiro CLI
- [ ] Invalid endpoints are handled gracefully

## Notes

**Important:** This tests the API server only. Kiro CLI processing is separate and requires:
- Kiro CLI installed and authenticated
- Template files accessible to Kiro CLI
- Kiro CLI configured to handle JSON input with template + parameters

The API server's job is just to:
1. Map URL → template filename
2. Queue task in DynamoDB
3. Pass JSON to Kiro CLI
4. Return results

## Troubleshooting

### Server won't start
```bash
# Check if port is in use
lsof -i :8081

# Check DynamoDB access
aws dynamodb list-tables --region us-east-1
```

### Tasks stay pending
- Kiro CLI not running
- Kiro CLI not processing queue
- Check Kiro CLI logs

### Template not found
- Check template filename matches URL mapping
- Verify file exists in `templates/` directory
- Check file permissions

## Success Criteria

✅ All tests pass  
✅ Tasks are created  
✅ Template mapping works  
✅ Results can be retrieved  
✅ Error handling works  

The API is working correctly when tasks are created and queued. Kiro CLI processing is a separate concern.
