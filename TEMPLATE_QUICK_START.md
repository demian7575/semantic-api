# Template Quick Start

## 📁 File Structure

```
kiro-api-project/
├── src/
│   └── kiro-api-server.js    # Loads templates from files
├── templates/                 # Template directory
│   ├── endpoint-base.json     # Generic baseline ⭐
│   ├── crud-endpoints.json    # CRUD example
│   └── your-template.json     # Add your templates here
```

## 🎯 Generic Baseline Template

**File:** `templates/endpoint-base.json`

This is the **baseline for all endpoints**. It includes:
- ✅ HTTP method (GET, POST, PUT, DELETE, PATCH)
- ✅ Path definition
- ✅ Language selection (nodejs, python, go)
- ✅ Database integration (optional)
- ✅ Authentication (optional)
- ✅ Request/response schemas
- ✅ Validation & error handling

## 🚀 Quick Usage

### 1. Use Baseline Template

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "endpoint-base",
    "parameters": {
      "method": "POST",
      "path": "/api/users",
      "description": "creates a new user",
      "language": "nodejs",
      "database": "dynamodb",
      "auth": true,
      "requestBody": "{name: string, email: string}",
      "validation": true
    }
  }'
```

### 2. Create Custom Template

```bash
cat > templates/my-endpoint.json << 'JSON'
{
  "id": "my-endpoint",
  "name": "My Endpoint",
  "description": "My custom endpoint",
  "category": "endpoint",
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
      "enum": ["nodejs", "python", "go"]
    }
  ],
  "prompt": "Create a REST endpoint for {{resource}} in {{language}}"
}
JSON
```

### 3. Restart & Use

```bash
# Restart server to load new template
npm start

# Use your template
curl -X POST http://localhost:8081/api/generate \
  -d '{"templateId":"my-endpoint","parameters":{"resource":"products","language":"nodejs"}}'
```

## 📋 Template Structure

```json
{
  "id": "template-id",              // Unique ID
  "name": "Display Name",           // Human-readable name
  "description": "What it does",    // Description
  "category": "endpoint",           // Category
  "parameters": [                   // Input parameters
    {
      "name": "param1",             // Parameter name
      "type": "string",             // Type: string|number|boolean
      "required": true,             // Required?
      "enum": ["opt1", "opt2"],     // Allowed values (optional)
      "description": "Help text"    // Description
    }
  ],
  "prompt": "Create {{param1}}"     // Kiro prompt with {{variables}}
}
```

## 🎨 Prompt Syntax

**Variables:**
```
{{variableName}}
```

**Conditionals:**
```
{{#if variableName}}
  Show this if variable exists
{{/if}}
```

**Example:**
```
Create a {{method}} endpoint at {{path}}.
{{#if database}}Use {{database}}.{{/if}}
{{#if auth}}Include auth.{{/if}}
```

## 📚 Available Templates

```bash
# List all templates
curl http://localhost:8081/api/templates

# Get template details
curl http://localhost:8081/api/templates/endpoint-base
```

## 💡 Common Patterns

### REST Endpoint
```json
{
  "id": "rest-endpoint",
  "parameters": [
    {"name": "method", "enum": ["GET","POST","PUT","DELETE"]},
    {"name": "path", "type": "string"},
    {"name": "language", "enum": ["nodejs","python","go"]}
  ],
  "prompt": "Create {{method}} {{path}} in {{language}}"
}
```

### CRUD Operations
```json
{
  "id": "crud",
  "parameters": [
    {"name": "resource", "type": "string"},
    {"name": "database", "enum": ["dynamodb","postgres"]}
  ],
  "prompt": "Generate CRUD for {{resource}} using {{database}}"
}
```

### Function
```json
{
  "id": "function",
  "parameters": [
    {"name": "name", "type": "string"},
    {"name": "description", "type": "string"}
  ],
  "prompt": "Create function {{name}} that {{description}}"
}
```

## 🔧 Tips

1. **Start with endpoint-base** - Copy and customize
2. **Use enums** - Limit choices for consistency
3. **Clear descriptions** - Help users understand
4. **Test prompts** - Verify output quality
5. **Restart server** - After adding new templates

---

**Full Documentation:** [TEMPLATE_STRUCTURE.md](TEMPLATE_STRUCTURE.md)
