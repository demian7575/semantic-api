# API Structure Explanation

## 🎯 Core Concept

The API now uses **dynamic endpoints and templates** instead of hardcoded ones.

---

## 📋 Endpoint Structure

An **endpoint** defines a REST API route:

```json
{
  "id": "create-user",           // Unique identifier
  "path": "/api/users",          // API path
  "method": "POST",              // HTTP method
  "description": "Create user",  // What it does
  "requestSchema": {             // Request format (optional)
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "email": { "type": "string" }
    }
  },
  "responseSchema": {            // Response format (optional)
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "name": { "type": "string" }
    }
  }
}
```

**Purpose:** Document and define API endpoints for your application.

---

## 🎨 Template Structure

A **template** defines how to generate code using Kiro CLI:

```json
{
  "id": "create-crud",                    // Unique identifier
  "name": "Generate CRUD",                // Display name
  "description": "Generate CRUD ops",     // What it does
  "parameters": [                         // Input parameters
    {
      "name": "resource",                 // Parameter name
      "type": "string",                   // Data type
      "required": true,                   // Is required?
      "description": "Resource name",     // Help text
      "enum": ["users", "products"]       // Allowed values (optional)
    }
  ],
  "prompt": "Generate CRUD for {{resource}} in {{language}}"  // Kiro prompt
}
```

**Purpose:** Define reusable code generation patterns.

---

## 🔄 How It Works

### 1. Create Template
```bash
POST /api/templates
{
  "id": "create-crud",
  "name": "Generate CRUD",
  "parameters": [...],
  "prompt": "Generate CRUD for {{resource}}"
}
```

### 2. Use Template
```bash
POST /api/generate
{
  "templateId": "create-crud",
  "parameters": {
    "resource": "users"
  }
}
```

### 3. Template Processing
```
Template: "Generate CRUD for {{resource}}"
Parameters: { "resource": "users" }
↓
Prompt: "Generate CRUD for users"
↓
Kiro CLI generates code
↓
Result returned
```

---

## 📊 Template Syntax

### Variables
```
{{variableName}}
```
Replaced with parameter value.

**Example:**
```
Template: "Create {{language}} function"
Parameters: { "language": "javascript" }
Result: "Create javascript function"
```

### Conditionals
```
{{#if variableName}}
  Content if true
{{/if}}
```
Shows content only if parameter exists.

**Example:**
```
Template: "Create API{{#if database}} using {{database}}{{/if}}"
Parameters: { "database": "postgres" }
Result: "Create API using postgres"

Parameters: {}
Result: "Create API"
```

---

## 🎯 Complete Example

### Create "Generate CRUD" Template

```bash
curl -X POST http://localhost:8081/api/templates \
  -H "Content-Type: application/json" \
  -d '{
    "id": "create-crud",
    "name": "Generate CRUD Operations",
    "description": "Generate complete CRUD API with database",
    "parameters": [
      {
        "name": "resource",
        "type": "string",
        "required": true,
        "description": "Resource name (e.g., users, products)"
      },
      {
        "name": "language",
        "type": "string",
        "required": true,
        "enum": ["nodejs", "python", "go"],
        "description": "Programming language"
      },
      {
        "name": "database",
        "type": "string",
        "required": false,
        "enum": ["dynamodb", "postgres", "mongodb"],
        "description": "Database type"
      }
    ],
    "prompt": "Generate CRUD operations for {{resource}} in {{language}}{{#if database}} using {{database}}{{/if}}. Include GET (list), GET (by id), POST (create), PUT (update), DELETE endpoints."
  }'
```

### Use the Template

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-crud",
    "parameters": {
      "resource": "users",
      "language": "nodejs",
      "database": "dynamodb"
    }
  }'

# Response:
{
  "taskId": "task-1234567890-abc",
  "status": "pending"
}
```

### Check Result

```bash
curl http://localhost:8081/api/task/task-1234567890-abc

# Response:
{
  "taskId": "task-1234567890-abc",
  "status": "completed",
  "result": "// Generated CRUD code here..."
}
```

---

## 🔑 Key Differences

### Old API (Hardcoded)
- ❌ Templates fixed in code
- ❌ Need code changes to add templates
- ❌ Limited flexibility

### New API (Dynamic)
- ✅ Create templates at runtime
- ✅ No code changes needed
- ✅ Unlimited flexibility
- ✅ Templates stored in memory (can be persisted to DB)

---

## 📚 Available Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/api/endpoints` | Create endpoint definition |
| GET | `/api/endpoints` | List all endpoints |
| GET | `/api/endpoints/:id` | Get endpoint details |
| POST | `/api/templates` | Create template |
| GET | `/api/templates` | List all templates |
| GET | `/api/templates/:id` | Get template details |
| POST | `/api/generate` | Generate code from template |
| GET | `/api/task/:id` | Get generation result |
| GET | `/health` | Health check |

---

## 💡 Use Cases

### 1. API Documentation
Create endpoint definitions to document your API:
```bash
POST /api/endpoints
{
  "id": "get-users",
  "path": "/api/users",
  "method": "GET",
  "description": "List all users"
}
```

### 2. Code Generation
Create templates for common patterns:
```bash
POST /api/templates
{
  "id": "create-function",
  "prompt": "Create {{language}} function named {{name}}"
}
```

### 3. Custom Workflows
Chain templates together:
1. Design API → 2. Generate CRUD → 3. Add Tests

---

## 🚀 Quick Start

```bash
# 1. Create your first template
curl -X POST http://localhost:8081/api/templates \
  -d '{"id":"hello","name":"Hello","parameters":[{"name":"name","type":"string","required":true}],"prompt":"Create a hello function for {{name}}"}'

# 2. Use it
curl -X POST http://localhost:8081/api/generate \
  -d '{"templateId":"hello","parameters":{"name":"World"}}'

# 3. Get result
curl http://localhost:8081/api/task/task-xxx
```

---

**Full Documentation:** [DYNAMIC_API.md](DYNAMIC_API.md)
