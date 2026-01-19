# Template Usage Examples

## 🎯 API Design Templates

### Example 1: Design English Word Test API

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "design-api",
    "parameters": {
      "domain": "English word test",
      "features": "word list, test creation, scoring, progress tracking, leaderboard",
      "includeSchemas": true
    }
  }'
```

**Result:** Complete API design with endpoints like:
- `GET /api/words` - List words
- `POST /api/tests` - Create test
- `POST /api/tests/:id/submit` - Submit answers
- `GET /api/users/progress` - Track progress
- Including JSON request/response schemas

---

### Example 2: Design Shopping Mall API

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "design-api",
    "parameters": {
      "domain": "shopping mall",
      "features": "products, cart, orders, payment, user profile",
      "includeSchemas": true
    }
  }'
```

**Result:** E-commerce API with:
- Product catalog endpoints
- Shopping cart operations
- Order management
- Payment processing
- User authentication

---

### Example 3: Create JSON Schema for Word Entity

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-schema",
    "parameters": {
      "entity": "Word",
      "fields": "word (string, required), pronunciation (string), level (enum: beginner|intermediate|advanced), definitions (array of objects), synonyms (array of strings)",
      "validation": true
    }
  }'
```

**Result:** JSON Schema with validation:
```json
{
  "type": "object",
  "required": ["word"],
  "properties": {
    "word": { "type": "string", "minLength": 1 },
    "pronunciation": { "type": "string" },
    "level": { "enum": ["beginner", "intermediate", "advanced"] },
    "definitions": { "type": "array" },
    "synonyms": { "type": "array", "items": { "type": "string" } }
  }
}
```

---

### Example 4: Generate CRUD for Words Resource

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "generate-crud",
    "parameters": {
      "resource": "words",
      "language": "nodejs",
      "database": "dynamodb",
      "auth": true
    }
  }'
```

**Result:** Complete CRUD implementation:
- GET /api/words (list with pagination)
- GET /api/words/:id (get by ID)
- POST /api/words (create - admin only)
- PUT /api/words/:id (update - admin only)
- DELETE /api/words/:id (delete - admin only)
- With JWT authentication middleware

---

### Example 5: Create Complete Test API

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-test-api",
    "parameters": {
      "testType": "English vocabulary test",
      "features": "multiple choice questions, scoring, time limit, progress tracking, leaderboard",
      "language": "nodejs"
    }
  }'
```

**Result:** Full test API with:
- Test session management
- Question generation
- Answer validation
- Score calculation
- Progress tracking
- Leaderboard system

---

### Example 6: Design Database Schema

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "design-database",
    "parameters": {
      "application": "word test application",
      "entities": "words, tests, users, test_results, progress, leaderboard",
      "dbType": "nosql"
    }
  }'
```

**Result:** DynamoDB schema design:
- Table structures
- Partition/sort keys
- GSI indexes
- Relationships
- Access patterns

---

## 🛠️ Code Generation Templates

### Example 7: Create Function

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-function",
    "parameters": {
      "name": "calculateTestScore",
      "description": "calculate test score based on correct answers, total questions, and time taken",
      "language": "javascript"
    }
  }'
```

---

### Example 8: Add Tests

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "add-tests",
    "parameters": {
      "code": "function calculateScore(correct, total) { return (correct / total) * 100; }",
      "framework": "jest"
    }
  }'
```

---

### Example 9: Refactor Code

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "refactor-code",
    "parameters": {
      "code": "function getWords(){let w=[];db.scan().then(r=>{r.Items.forEach(i=>w.push(i))});return w}",
      "goal": "readability"
    }
  }'
```

---

## 🔄 Complete Workflow Example

### Building a Word Test API from Scratch

**Step 1: Design the API**
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{"templateId": "design-api", "parameters": {"domain": "word test", "features": "words, tests, scoring", "includeSchemas": true}}'
```

**Step 2: Design Database**
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{"templateId": "design-database", "parameters": {"application": "word test", "entities": "words, tests, users", "dbType": "nosql"}}'
```

**Step 3: Generate CRUD for Words**
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{"templateId": "generate-crud", "parameters": {"resource": "words", "language": "nodejs", "database": "dynamodb", "auth": true}}'
```

**Step 4: Create Test Logic**
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{"templateId": "create-function", "parameters": {"name": "generateTest", "description": "select random words and create test questions", "language": "javascript"}}'
```

**Step 5: Add Tests**
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{"templateId": "add-tests", "parameters": {"code": "<generated code>", "framework": "jest"}}'
```

---

## 📊 Check Results

After submitting any template:

```bash
# Get task ID from response
TASK_ID="task-1234567890-abc"

# Check status
curl http://localhost:8081/api/task/$TASK_ID

# Response when completed:
{
  "taskId": "task-1234567890-abc",
  "status": "completed",
  "templateId": "design-api",
  "result": "... generated code/design ..."
}
```

---

## 💡 Tips

1. **Use `includeSchemas: true`** for API design to get complete request/response examples
2. **Combine templates** - Design API → Generate CRUD → Add Tests
3. **Be specific** in descriptions for better results
4. **Check task status** - Complex generations may take 30-60 seconds
5. **Save results** - Copy generated code to your project

---

**See also:**
- [TEMPLATES.md](TEMPLATES.md) - Complete template reference
- [API_REFERENCE.md](API_REFERENCE.md) - Quick API reference
