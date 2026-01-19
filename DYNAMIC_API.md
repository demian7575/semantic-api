# Dynamic Endpoint & Template API

## Overview

The Kiro API now supports **dynamic endpoint and template creation**. Instead of hardcoded templates, you can create custom endpoints and templates at runtime.

## Core Concepts

### 1. Endpoint
An endpoint defines a REST API route with its method, path, and behavior.

### 2. Template
A template defines how to generate code/content using Kiro CLI with parameterized prompts.

---

## API Endpoints

### Endpoint Management

#### POST /api/endpoints
Create a new endpoint.

**Request Body:**
```json
{
  "id": "create-user",
  "path": "/api/users",
  "method": "POST",
  "description": "Create a new user",
  "requestSchema": {
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "email": { "type": "string" }
    },
    "required": ["name", "email"]
  },
  "responseSchema": {
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "name": { "type": "string" },
      "email": { "type": "string" }
    }
  }
}
```

**Response:**
```json
{
  "message": "Endpoint created",
  "endpoint": { ... }
}
```

---

#### GET /api/endpoints
List all endpoints.

**Response:**
```json
{
  "endpoints": [
    {
      "id": "create-user",
      "path": "/api/users",
      "method": "POST",
      "description": "Create a new user"
    }
  ]
}
```

---

#### GET /api/endpoints/:id
Get endpoint details.

**Response:**
```json
{
  "id": "create-user",
  "path": "/api/users",
  "method": "POST",
  "description": "Create a new user",
  "requestSchema": { ... },
  "responseSchema": { ... }
}
```

---

### Template Management

#### POST /api/templates
Create a new template.

**Request Body:**
```json
{
  "id": "create-crud",
  "name": "Generate CRUD Operations",
  "description": "Generate complete CRUD API",
  "parameters": [
    {
      "name": "resource",
      "type": "string",
      "required": true,
      "description": "Resource name"
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
      "required": true,
      "enum": ["dynamodb", "postgres", "mongodb"],
      "description": "Database type"
    }
  ],
  "prompt": "Generate CRUD operations for {{resource}} in {{language}} using {{database}}"
}
```

**Response:**
```json
{
  "message": "Template created",
  "template": { ... }
}
```

---

#### GET /api/templates
List all templates.

**Response:**
```json
{
  "templates": [
    {
      "id": "create-crud",
      "name": "Generate CRUD Operations",
      "description": "Generate complete CRUD API",
      "parameters": [ ... ]
    }
  ]
}
```

---

#### GET /api/templates/:id
Get template details.

**Response:**
```json
{
  "id": "create-crud",
  "name": "Generate CRUD Operations",
  "description": "Generate complete CRUD API",
  "parameters": [ ... ],
  "prompt": "Generate CRUD operations for {{resource}} in {{language}} using {{database}}"
}
```

---

#### POST /api/generate
Generate code using a template.

**Request Body:**
```json
{
  "templateId": "create-crud",
  "parameters": {
    "resource": "users",
    "language": "nodejs",
    "database": "dynamodb"
  }
}
```

**Response:**
```json
{
  "taskId": "task-1234567890-abc",
  "status": "pending",
  "templateId": "create-crud"
}
```

---

## Data Structures

### Endpoint Structure

```typescript
{
  id: string;              // Unique identifier
  path: string;            // API path (e.g., "/api/users")
  method: string;          // HTTP method (GET, POST, PUT, DELETE)
  description: string;     // Endpoint description
  requestSchema?: object;  // JSON schema for request
  responseSchema?: object; // JSON schema for response
  auth?: boolean;          // Requires authentication
  rateLimit?: number;      // Requests per minute
}
```

### Template Structure

```typescript
{
  id: string;              // Unique identifier
  name: string;            // Display name
  description: string;     // Template description
  parameters: Array<{      // Template parameters
    name: string;          // Parameter name
    type: string;          // Data type (string, number, boolean)
    required: boolean;     // Is required
    enum?: string[];       // Allowed values
    description: string;   // Parameter description
  }>;
  prompt: string;          // Prompt template with {{placeholders}}
}
```

### Prompt Template Syntax

**Variables:**
```
{{variableName}}
```

**Conditionals:**
```
{{#if variableName}}
  This appears if variableName is truthy
{{/if}}
```

**Example:**
```
Create a {{language}} API for {{resource}}{{#if database}} using {{database}}{{/if}}
```

---

## Complete Examples

### Example 1: Create CRUD Template

```bash
# 1. Create template
curl -X POST http://localhost:8081/api/templates \
  -H "Content-Type: application/json" \
  -d '{
    "id": "create-crud",
    "name": "Generate CRUD",
    "description": "Generate CRUD operations",
    "parameters": [
      {
        "name": "resource",
        "type": "string",
        "required": true,
        "description": "Resource name"
      },
      {
        "name": "language",
        "type": "string",
        "required": true,
        "enum": ["nodejs", "python", "go"],
        "description": "Programming language"
      }
    ],
    "prompt": "Generate CRUD operations for {{resource}} in {{language}}"
  }'

# 2. Use template
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-crud",
    "parameters": {
      "resource": "users",
      "language": "nodejs"
    }
  }'

# 3. Check result
curl http://localhost:8081/api/task/task-xxx
```

---

### Example 2: Create Endpoint Definition

```bash
# Create endpoint definition
curl -X POST http://localhost:8081/api/endpoints \
  -H "Content-Type: application/json" \
  -d '{
    "id": "list-users",
    "path": "/api/users",
    "method": "GET",
    "description": "List all users",
    "responseSchema": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "name": { "type": "string" },
          "email": { "type": "string" }
        }
      }
    }
  }'

# List all endpoints
curl http://localhost:8081/api/endpoints
```

---

## Benefits

1. **Dynamic**: Create templates at runtime without code changes
2. **Flexible**: Define any prompt structure with parameters
3. **Reusable**: Templates can be shared and reused
4. **Discoverable**: List all available templates via API
5. **Validated**: Parameter validation built-in

---

## Migration from Old API

**Old (Hardcoded):**
```bash
curl -X POST /api/generate \
  -d '{"templateId": "create-api", "parameters": {...}}'
```

**New (Dynamic):**
```bash
# 1. Create template first
curl -X POST /api/templates -d '{...template definition...}'

# 2. Use template (same as before)
curl -X POST /api/generate \
  -d '{"templateId": "create-api", "parameters": {...}}'
```

---

## Next Steps

1. Create your first template
2. Define your API endpoints
3. Generate code using templates
4. Build your application!
