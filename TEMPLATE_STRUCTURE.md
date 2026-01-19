# Template Structure Guide

## 📁 Directory Structure

```
templates/
├── endpoint-base.json       # Generic endpoint template (baseline)
├── crud-endpoints.json      # CRUD operations template
├── custom-template.json     # Your custom templates
└── ...
```

## 📋 Generic Template Structure

Every template file must follow this structure:

```json
{
  "id": "unique-template-id",
  "name": "Human Readable Name",
  "description": "What this template does",
  "category": "endpoint|function|test|other",
  "parameters": [
    {
      "name": "parameterName",
      "type": "string|number|boolean",
      "required": true|false,
      "enum": ["option1", "option2"],
      "description": "Parameter description"
    }
  ],
  "prompt": "Template with {{variables}} and {{#if conditional}}optional{{/if}} parts"
}
```

## 🎯 Baseline Endpoint Template

The `endpoint-base.json` is the **generic baseline** for all endpoints:

### Structure
```json
{
  "id": "endpoint-base",
  "name": "Generic REST Endpoint",
  "description": "Base template for creating any REST endpoint",
  "category": "endpoint",
  "parameters": [
    {
      "name": "method",
      "type": "string",
      "required": true,
      "enum": ["GET", "POST", "PUT", "DELETE", "PATCH"],
      "description": "HTTP method"
    },
    {
      "name": "path",
      "type": "string",
      "required": true,
      "description": "Endpoint path"
    },
    {
      "name": "description",
      "type": "string",
      "required": true,
      "description": "What this endpoint does"
    },
    {
      "name": "language",
      "type": "string",
      "required": true,
      "enum": ["nodejs", "python", "go"]
    },
    {
      "name": "database",
      "type": "string",
      "required": false,
      "enum": ["dynamodb", "postgres", "mongodb", "none"]
    },
    {
      "name": "auth",
      "type": "boolean",
      "required": false
    },
    {
      "name": "requestBody",
      "type": "string",
      "required": false,
      "description": "Request schema"
    },
    {
      "name": "responseBody",
      "type": "string",
      "required": false,
      "description": "Response schema"
    },
    {
      "name": "validation",
      "type": "boolean",
      "required": false
    },
    {
      "name": "errorHandling",
      "type": "boolean",
      "required": false
    }
  ],
  "prompt": "Create a {{method}} endpoint at {{path}} in {{language}} that {{description}}..."
}
```

### Usage Example
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
      "responseBody": "{id: string, name: string, email: string}",
      "validation": true,
      "errorHandling": true
    }
  }'
```

## 🔧 Creating Custom Templates

### Example: Word Test Endpoint

```json
{
  "id": "word-test-endpoint",
  "name": "Word Test Endpoint",
  "description": "Create endpoint for word testing application",
  "category": "endpoint",
  "parameters": [
    {
      "name": "endpointType",
      "type": "string",
      "required": true,
      "enum": ["getWords", "createTest", "submitTest", "getProgress"],
      "description": "Type of word test endpoint"
    },
    {
      "name": "language",
      "type": "string",
      "required": true,
      "enum": ["nodejs", "python"],
      "description": "Programming language"
    },
    {
      "name": "includeAuth",
      "type": "boolean",
      "required": false,
      "description": "Include user authentication"
    }
  ],
  "prompt": "Create a {{endpointType}} endpoint for a word test application in {{language}}.{{#if includeAuth}} Include JWT authentication.{{/if}} Include proper error handling and input validation."
}
```

Save as `templates/word-test-endpoint.json`

## 📊 Template Field Reference

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier (kebab-case) |
| `name` | string | Display name |
| `description` | string | What the template does |
| `parameters` | array | Input parameters |
| `prompt` | string | Kiro CLI prompt template |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `category` | string | Template category |
| `version` | string | Template version |
| `author` | string | Template author |
| `tags` | array | Search tags |

### Parameter Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Parameter name |
| `type` | string | Data type (string, number, boolean) |
| `required` | boolean | Is required |
| `enum` | array | Allowed values (optional) |
| `description` | string | Help text |
| `default` | any | Default value (optional) |

## 🎨 Prompt Template Syntax

### Variables
```
{{variableName}}
```
Replaced with parameter value.

### Conditionals
```
{{#if variableName}}
  Content shown if variable is truthy
{{/if}}
```

### Example Prompt
```
Create a {{method}} endpoint at {{path}} in {{language}}.
{{#if database}}Use {{database}} for storage.{{/if}}
{{#if auth}}Include authentication.{{/if}}
Request: {{requestBody}}
Response: {{responseBody}}
```

## 🚀 Quick Start

### 1. Create Template File

```bash
cat > templates/my-endpoint.json << 'EOF'
{
  "id": "my-endpoint",
  "name": "My Custom Endpoint",
  "description": "Creates my custom endpoint",
  "category": "endpoint",
  "parameters": [
    {
      "name": "resource",
      "type": "string",
      "required": true,
      "description": "Resource name"
    }
  ],
  "prompt": "Create a REST endpoint for {{resource}}"
}
EOF
```

### 2. Restart Server

```bash
npm start
```

### 3. Use Template

```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{"templateId":"my-endpoint","parameters":{"resource":"users"}}'
```

## 📚 Best Practices

1. **Use endpoint-base as starting point** - Copy and customize
2. **Clear parameter names** - Use descriptive names
3. **Provide enums** - Limit choices for consistency
4. **Detailed descriptions** - Help users understand parameters
5. **Test prompts** - Verify generated code quality
6. **Version templates** - Add version field for tracking
7. **Categorize** - Use category field for organization

## 🔍 Template Discovery

```bash
# List all templates
curl http://localhost:8081/api/templates

# Get template details
curl http://localhost:8081/api/templates/endpoint-base
```

## 📝 Template Validation

Templates are validated on load:
- ✅ Required fields present
- ✅ Valid JSON structure
- ✅ Parameter types correct
- ❌ Invalid templates are skipped with error log

---

**See also:**
- [endpoint-base.json](../templates/endpoint-base.json) - Generic baseline
- [crud-endpoints.json](../templates/crud-endpoints.json) - CRUD example
