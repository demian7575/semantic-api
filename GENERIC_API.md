# Generic Kiro API

## Ultra-Simple Design

The API is now **completely generic** - it just passes JSON to Kiro CLI.

## How It Works

```
Client → POST /api/generate → Kiro API → Kiro CLI
                                ↓
                        JSON: {template, parameters}
```

## API Endpoint

### POST /api/generate

**Request:**
```json
{
  "template": "templates/create-user-endpoint.md",
  "parameters": {
    "language": "nodejs",
    "database": "dynamodb",
    "auth": true
  }
}
```

**Response:**
```json
{
  "taskId": "task-1234567890-abc",
  "status": "pending"
}
```

### GET /api/task/:taskId

**Response:**
```json
{
  "taskId": "task-1234567890-abc",
  "status": "completed",
  "result": "...Kiro CLI output..."
}
```

## What Kiro CLI Receives

```json
{
  "template": "templates/create-user-endpoint.md",
  "parameters": {
    "language": "nodejs",
    "database": "dynamodb",
    "auth": true
  }
}
```

Kiro CLI is responsible for:
1. Loading the template file
2. Substituting parameters
3. Interpreting role/constraints/intent
4. Generating output per schema
5. Returning result

## Complete Example

### 1. Template File

**File:** `templates/create-user-endpoint.md`

```markdown
# Create User Endpoint

## Parameters
- `language` (required): nodejs | python | go
- `database` (required): dynamodb | postgres
- `auth` (optional): true | false

## Role
You are an expert backend developer.

## Constraints
- Use {{language}} best practices
- Include error handling

## Intent
Create a POST /api/users endpoint.

## Instructions
1. Create handler in {{language}}
2. Validate input (name, email)
3. Save to {{database}}
4. {{#if auth}}Add JWT authentication{{/if}}
5. Return JSON response

## Expected Output
```json
{
  "code": "string - generated code",
  "language": "string",
  "database": "string"
}
```
```

### 2. Client Request

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "template": "templates/create-user-endpoint.md",
    "parameters": {
      "language": "nodejs",
      "database": "dynamodb",
      "auth": true
    }
  }'
```

### 3. API Processing

```javascript
// Receive request
const input = {
  template: "templates/create-user-endpoint.md",
  parameters: { language: "nodejs", database: "dynamodb", auth: true }
};

// Send to Kiro CLI as JSON
kiroSession.sendMessage(JSON.stringify(input));
```

### 4. Kiro CLI Processing

Kiro CLI receives JSON and:
1. Loads `templates/create-user-endpoint.md`
2. Substitutes `{{language}}` → `nodejs`
3. Substitutes `{{database}}` → `dynamodb`
4. Processes `{{#if auth}}` → includes auth code
5. Reads role/constraints/intent/instructions
6. Generates code per expected output schema
7. Returns result

### 5. Result

```json
{
  "taskId": "task-123",
  "status": "completed",
  "result": {
    "code": "const express = require('express')...",
    "language": "nodejs",
    "database": "dynamodb"
  }
}
```

## Benefits

### 1. **Zero Logic**
- No template loading
- No parsing
- No parameter substitution
- Just pass JSON through

### 2. **Completely Generic**
- Works with any template
- Works with any parameters
- No hardcoded logic

### 3. **Kiro CLI Handles Everything**
- Template loading
- Parameter substitution
- Markdown interpretation
- Output generation

### 4. **Simple Code**
- ~150 lines total
- No dependencies (except AWS SDK)
- Easy to maintain

## API Contract

### Input Schema
```json
{
  "template": "string - path to template file",
  "parameters": {
    "key1": "value1",
    "key2": "value2"
  }
}
```

### Output Schema
Whatever Kiro CLI returns (defined in template's "Expected Output" section)

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Client                            │
└────────────────────────┬────────────────────────────────┘
                         │ POST /api/generate
                         │ {template, parameters}
                         ▼
┌─────────────────────────────────────────────────────────┐
│                     Kiro API Server                      │
│  - Receives JSON                                         │
│  - Creates task in DynamoDB                              │
│  - Queues for processing                                 │
│  - Returns taskId                                        │
└────────────────────────┬────────────────────────────────┘
                         │ JSON.stringify({template, parameters})
                         ▼
┌─────────────────────────────────────────────────────────┐
│                      Kiro CLI                            │
│  - Loads template file                                   │
│  - Substitutes parameters                                │
│  - Interprets markdown                                   │
│  - Generates output                                      │
│  - Returns result                                        │
└────────────────────────┬────────────────────────────────┘
                         │ Result
                         ▼
┌─────────────────────────────────────────────────────────┐
│                      DynamoDB                            │
│  - Stores task status                                    │
│  - Stores result                                         │
└─────────────────────────────────────────────────────────┘
```

## Code Size Comparison

| Approach | Lines of Code | Complexity |
|----------|--------------|------------|
| Parse markdown + build prompt | ~300 | High |
| Load template + substitute | ~200 | Medium |
| **Pass JSON to Kiro CLI** | **~150** | **Low** |

## What Changed

**Before:**
```javascript
// Load template
const template = loadTemplate(templateId);
// Parse markdown
const parsed = parseMarkdown(template);
// Substitute parameters
const prompt = substitute(parsed, parameters);
// Send to Kiro
kiro.send(prompt);
```

**After:**
```javascript
// Send JSON to Kiro
kiro.send(JSON.stringify({ template, parameters }));
```

## Responsibilities

### Kiro API Server
- ✅ Receive HTTP requests
- ✅ Queue tasks
- ✅ Manage Kiro CLI sessions
- ✅ Store results in DynamoDB
- ✅ Return results to client

### Kiro CLI
- ✅ Load template files
- ✅ Substitute parameters
- ✅ Interpret markdown structure
- ✅ Generate output per schema
- ✅ Return result

## Usage Examples

### Example 1: Create Endpoint
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{
    "template": "templates/create-endpoint.md",
    "parameters": {
      "method": "POST",
      "path": "/api/users",
      "language": "nodejs"
    }
  }'
```

### Example 2: Generate CRUD
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{
    "template": "templates/crud-operations.md",
    "parameters": {
      "resource": "products",
      "database": "postgres"
    }
  }'
```

### Example 3: Add Tests
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{
    "template": "templates/add-tests.md",
    "parameters": {
      "code": "function add(a,b){return a+b}",
      "framework": "jest"
    }
  }'
```

## Summary

The API is now **ultra-generic**:
- Just 2 endpoints: `/api/generate` and `/api/task/:id`
- No template logic
- No parsing logic
- No substitution logic
- Just passes JSON to Kiro CLI
- Kiro CLI does everything

**Result:** Simplest possible implementation! 🎉
