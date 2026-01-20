# Semantic API Templates

## Available Templates

### 1. create-api
**Create REST API**

Generate a REST API endpoint with CRUD operations.

**Parameters:**
- `resource` (string, required) - Resource name (e.g., "user", "product")
- `language` (string, required) - Programming language: `nodejs` | `python` | `go`
- `database` (string, optional) - Database type: `dynamodb` | `postgres` | `mongodb`

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-api",
    "parameters": {
      "resource": "user",
      "language": "nodejs",
      "database": "dynamodb"
    }
  }'
```

---

### 2. create-function
**Create Function**

Generate a function with specified behavior.

**Parameters:**
- `name` (string, required) - Function name
- `description` (string, required) - What the function should do
- `language` (string, required) - Programming language: `javascript` | `python` | `java` | `go`

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-function",
    "parameters": {
      "name": "calculateTotal",
      "description": "sum an array of numbers",
      "language": "javascript"
    }
  }'
```

---

### 3. add-tests
**Add Unit Tests**

Generate unit tests for existing code.

**Parameters:**
- `code` (string, required) - Code to test
- `framework` (string, optional) - Test framework: `jest` | `mocha` | `pytest` | `junit`

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "add-tests",
    "parameters": {
      "code": "function add(a, b) { return a + b; }",
      "framework": "jest"
    }
  }'
```

---

### 4. refactor-code
**Refactor Code**

Improve code quality and structure.

**Parameters:**
- `code` (string, required) - Code to refactor
- `goal` (string, required) - Refactoring goal: `performance` | `readability` | `maintainability`

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "refactor-code",
    "parameters": {
      "code": "var x=1;if(x>0){console.log(x)}",
      "goal": "readability"
    }
  }'
```

---

### 5. fix-bug
**Fix Bug**

Debug and fix code issues.

**Parameters:**
- `code` (string, required) - Code with bug
- `error` (string, required) - Error message or description

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "fix-bug",
    "parameters": {
      "code": "const arr = [1,2,3]; arr[5].toString();",
      "error": "Cannot read property toString of undefined"
    }
  }'
```

---

### 6. add-documentation
**Add Documentation**

Generate code documentation.

**Parameters:**
- `code` (string, required) - Code to document
- `style` (string, optional) - Documentation style: `jsdoc` | `docstring` | `javadoc`

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "add-documentation",
    "parameters": {
      "code": "function multiply(a, b) { return a * b; }",
      "style": "jsdoc"
    }
  }'
```

---

## API Endpoints

### GET /api/templates
List all available templates.

**Response:**
```json
{
  "templates": ["create-api", "create-function", "add-tests", "refactor-code", "fix-bug", "add-documentation"]
}
```

### GET /api/templates/:templateId
Get template details.

**Response:**
```json
{
  "id": "create-api",
  "name": "Create REST API",
  "description": "Generate a REST API endpoint with CRUD operations",
  "parameters": [
    {
      "name": "resource",
      "type": "string",
      "required": true,
      "description": "Resource name"
    }
  ]
}
```

### POST /api/generate
Generate code using a template.

**Request:**
```json
{
  "templateId": "create-function",
  "parameters": {
    "name": "hello",
    "description": "print hello world",
    "language": "python"
  },
  "sessionId": "optional"
}
```

**Response:**
```json
{
  "taskId": "task-1234567890-abc",
  "status": "pending",
  "templateId": "create-function"
}
```

### GET /api/task/:taskId
Get task result (same as before).

### GET /health
Health check (same as before).

---

## 🎯 API Design Templates

### 7. design-api
**Design API Endpoints**

Generate REST API endpoint design with JSON schemas.

**Parameters:**
- `domain` (string, required) - Application domain (e.g., "shopping mall", "word test")
- `features` (string, required) - Key features (comma-separated)
- `includeSchemas` (boolean, optional) - Include JSON schemas

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "design-api",
    "parameters": {
      "domain": "English word test",
      "features": "word list, test creation, scoring, progress tracking",
      "includeSchemas": true
    }
  }'
```

---

### 8. create-schema
**Create JSON Schema**

Generate JSON schema for data models.

**Parameters:**
- `entity` (string, required) - Entity name (e.g., "User", "Product")
- `fields` (string, required) - Fields description
- `validation` (boolean, optional) - Include validation rules

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-schema",
    "parameters": {
      "entity": "Word",
      "fields": "word (string), pronunciation (string), level (enum), definitions (array)",
      "validation": true
    }
  }'
```

---

### 9. generate-crud
**Generate CRUD Operations**

Generate complete CRUD API with database operations.

**Parameters:**
- `resource` (string, required) - Resource name
- `language` (string, required) - Programming language: `nodejs` | `python` | `go`
- `database` (string, required) - Database type: `dynamodb` | `postgres` | `mongodb`
- `auth` (boolean, optional) - Include authentication

**Example:**
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

---

### 10. create-test-api
**Create Test/Quiz API**

Generate API for test/quiz applications.

**Parameters:**
- `testType` (string, required) - Test type (e.g., "word test", "math quiz")
- `features` (string, required) - Features (e.g., "scoring, progress tracking")
- `language` (string, required) - Programming language: `nodejs` | `python` | `go`

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-test-api",
    "parameters": {
      "testType": "English word test",
      "features": "word list, multiple choice tests, scoring, leaderboard, progress tracking",
      "language": "nodejs"
    }
  }'
```

---

### 11. design-database
**Design Database Schema**

Generate database schema design.

**Parameters:**
- `application` (string, required) - Application type
- `entities` (string, required) - Main entities (comma-separated)
- `dbType` (string, required) - Database type: `sql` | `nosql`

**Example:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "design-database",
    "parameters": {
      "application": "word test application",
      "entities": "words, tests, users, progress, leaderboard",
      "dbType": "nosql"
    }
  }'
```
