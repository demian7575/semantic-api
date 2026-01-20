# Semantic API Quick Reference

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/templates` | List all templates |
| GET | `/api/templates/:id` | Get template details |
| POST | `/api/generate` | Generate code from template |
| GET | `/api/task/:taskId` | Get task result |
| GET | `/health` | Health check |

## Templates

| ID | Name | Use Case |
|----|------|----------|
| `create-api` | Create REST API | Generate CRUD endpoints |
| `create-function` | Create Function | Generate specific functions |
| `add-tests` | Add Unit Tests | Generate test cases |
| `refactor-code` | Refactor Code | Improve code quality |
| `fix-bug` | Fix Bug | Debug and fix issues |
| `add-documentation` | Add Documentation | Generate docs |
| `design-api` | Design API Endpoints | Design REST API with schemas |
| `create-schema` | Create JSON Schema | Generate data model schemas |
| `generate-crud` | Generate CRUD | Complete CRUD with DB |
| `create-test-api` | Create Test/Quiz API | Test application APIs |
| `design-database` | Design Database | Database schema design |

## Quick Examples

### List Templates
```bash
curl http://localhost:8081/api/templates
```

### Get Template Info
```bash
curl http://localhost:8081/api/templates/create-function
```

### Generate Code
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
# Returns: {"taskId": "task-xxx", "status": "pending"}
```

### Check Result
```bash
curl http://localhost:8081/api/task/task-xxx
# Returns: {"taskId": "task-xxx", "status": "completed", "result": "...code..."}
```

## Template Parameters

### create-api
- `resource` (required) - Resource name
- `language` (required) - `nodejs` | `python` | `go`
- `database` (optional) - `dynamodb` | `postgres` | `mongodb`

### create-function
- `name` (required) - Function name
- `description` (required) - What it does
- `language` (required) - `javascript` | `python` | `java` | `go`

### add-tests
- `code` (required) - Code to test
- `framework` (optional) - `jest` | `mocha` | `pytest` | `junit`

### refactor-code
- `code` (required) - Code to refactor
- `goal` (required) - `performance` | `readability` | `maintainability`

### fix-bug
- `code` (required) - Code with bug
- `error` (required) - Error description

### add-documentation
- `code` (required) - Code to document
- `style` (optional) - `jsdoc` | `docstring` | `javadoc`

## Response Format

### Success
```json
{
  "taskId": "task-1234567890-abc",
  "status": "pending|processing|completed",
  "templateId": "create-function",
  "result": "...generated code..." // when completed
}
```

### Error
```json
{
  "error": "Invalid template"
}
```

---

**Full Documentation:** [TEMPLATES.md](TEMPLATES.md)
