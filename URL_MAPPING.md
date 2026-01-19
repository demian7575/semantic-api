# URL-to-Template Mapping

## Ultra-Minimal Design

**Every endpoint is automatically mapped to a template file!**

## Mapping Rule

```
METHOD /path/to/endpoint → templates/METHOD-path-to-endpoint.md
```

## Examples

| Request | Template File |
|---------|--------------|
| `POST /api/users` | `templates/POST-api-users.md` |
| `GET /api/users` | `templates/GET-api-users.md` |
| `PUT /api/users/123` | `templates/PUT-api-users-123.md` |
| `DELETE /api/products` | `templates/DELETE-api-products.md` |
| `POST /auth/login` | `templates/POST-auth-login.md` |

## How It Works

```
1. Client: POST /api/users {"name":"John"}
2. Server: template = "templates/POST-api-users.md"
3. Server: Send to Kiro CLI: {template, parameters: {name:"John"}}
4. Kiro CLI: Load template, substitute params, generate output
5. Server: Return taskId
```

## Complete Example

### 1. Create Template

**File:** `templates/POST-api-users.md`

```markdown
# Create User

## Parameters
- `name` (required): string
- `email` (required): string
- `age` (optional): number

## Role
You are an expert backend developer.

## Intent
Create a new user with validation.

## Instructions
1. Validate input: name ({{name}}), email ({{email}})
2. Generate unique ID
3. Save to database
4. Return user object

## Expected Output
```json
{
  "id": "string",
  "name": "{{name}}",
  "email": "{{email}}",
  "createdAt": "timestamp"
}
```
```

### 2. Make Request

```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }'
```

### 3. Server Processing

```javascript
// Extract from request
const method = "POST";
const path = "/api/users";
const body = { name: "John Doe", email: "john@example.com", age: 30 };

// Map to template
const template = "templates/POST-api-users.md";

// Send to Kiro CLI
kiro.send(JSON.stringify({
  template: template,
  parameters: body
}));
```

### 4. Response

```json
{
  "taskId": "task-1234567890-abc",
  "status": "pending"
}
```

### 5. Get Result

```bash
curl http://localhost:8081/task/task-1234567890-abc
```

```json
{
  "taskId": "task-1234567890-abc",
  "status": "completed",
  "result": {
    "id": "user-123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2026-01-19T16:52:00Z"
  }
}
```

## More Examples

### Example 1: Get Users

**Request:**
```bash
GET /api/users?limit=10&offset=0
```

**Template:** `templates/GET-api-users.md`

**Parameters:**
```json
{
  "limit": "10",
  "offset": "0"
}
```

### Example 2: Update User

**Request:**
```bash
PUT /api/users/123
{"name": "Jane Doe"}
```

**Template:** `templates/PUT-api-users-123.md`

**Parameters:**
```json
{
  "name": "Jane Doe"
}
```

### Example 3: Login

**Request:**
```bash
POST /auth/login
{"email": "user@example.com", "password": "secret"}
```

**Template:** `templates/POST-auth-login.md`

**Parameters:**
```json
{
  "email": "user@example.com",
  "password": "secret"
}
```

## Code Simplification

### Before (150 lines)
```javascript
// Parse URL
// Check endpoint type
// Load template
// Validate parameters
// Build request
// Send to Kiro
```

### After (130 lines)
```javascript
// Map URL to template filename
const template = `templates/${req.method}${url.pathname.replace(/\//g, '-')}.md`;

// Send to Kiro
kiro.send(JSON.stringify({ template, parameters: body }));
```

## Benefits

### 1. **Zero Configuration**
- No endpoint definitions
- No routing logic
- No parameter mapping

### 2. **File-Based Routing**
- Add template file = Add endpoint
- Delete template file = Remove endpoint
- Rename template file = Change endpoint

### 3. **Self-Documenting**
- Template filename shows endpoint
- Template content shows behavior
- No separate API docs needed

### 4. **Completely Generic**
- Works for any HTTP method
- Works for any URL path
- Works for any parameters

## Special Endpoints

### Health Check
```
GET /health → Built-in (no template)
```

### Task Status
```
GET /task/:taskId → Built-in (no template)
```

### Everything Else
```
METHOD /any/path → templates/METHOD-any-path.md
```

## Template Organization

```
templates/
├── POST-api-users.md          # POST /api/users
├── GET-api-users.md           # GET /api/users
├── PUT-api-users-{id}.md      # PUT /api/users/:id
├── DELETE-api-users-{id}.md   # DELETE /api/users/:id
├── POST-auth-login.md         # POST /auth/login
├── POST-auth-register.md      # POST /auth/register
├── GET-products.md            # GET /products
└── POST-orders.md             # POST /orders
```

## Dynamic Path Parameters

For paths with IDs like `/api/users/123`:

**Option 1: Generic Template**
```
templates/PUT-api-users-{id}.md
```

**Option 2: Specific Template**
```
templates/PUT-api-users-123.md
```

Kiro CLI can handle both patterns.

## Query Parameters

Automatically included in parameters:

```bash
GET /api/users?limit=10&offset=20
```

Parameters:
```json
{
  "limit": "10",
  "offset": "20"
}
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Any HTTP Request                  │
│              METHOD /any/path + body                 │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                  Kiro API Server                     │
│  template = "templates/METHOD-path.md"               │
│  kiro.send({template, parameters: body})             │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                     Kiro CLI                         │
│  - Load template file                                │
│  - Substitute parameters                             │
│  - Generate output                                   │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                    DynamoDB                          │
│  - Store task & result                               │
└─────────────────────────────────────────────────────┘
```

## Code Size

| Version | Lines | Description |
|---------|-------|-------------|
| Original | 300+ | Parse templates, build prompts |
| Generic | 150 | Pass JSON to Kiro |
| **URL Mapping** | **130** | **Map URL to template** |

## Summary

**The entire API is now just:**
1. Map URL + method to template filename
2. Pass template + parameters to Kiro CLI
3. Return taskId
4. Store result

**That's it!** 🎉

No routing, no parsing, no logic - just filename mapping!
