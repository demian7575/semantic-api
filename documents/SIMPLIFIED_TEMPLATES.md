# Simplified Markdown Template System

## How It Works

```
1. Client sends parameters
2. Server loads markdown template file
3. Server substitutes {{parameters}} in markdown
4. Server sends ENTIRE markdown to Kiro CLI
5. Kiro CLI reads role/constraints/intent/instructions
6. Kiro CLI generates output according to template
7. Server returns result
```

## Key Insight

**No parsing needed!** Kiro CLI understands markdown structure:
- Role
- Constraints
- Intent
- Instructions
- Expected Output (including JSON schema)

## Example Flow

### 1. Template File: `templates/create-user-endpoint.md`

```markdown
# Create User Endpoint

## Parameters
- `language` (required): nodejs | python | go
- `database` (required): dynamodb | postgres

## Role
You are an expert backend developer.

## Constraints
- Use {{language}} best practices
- Include error handling
- Follow RESTful conventions

## Intent
Create a POST /api/users endpoint.

## Instructions
1. Create endpoint handler in {{language}}
2. Validate input (name, email)
3. Save to {{database}}
4. Return JSON response

## Expected Output
```json
{
  "code": "...generated code...",
  "language": "{{language}}",
  "database": "{{database}}"
}
```

## Success Criteria
- Code compiles
- Includes validation
- Proper error handling
```

### 2. Client Request

```bash
curl -X POST http://localhost:8081/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "templateId": "create-user-endpoint",
    "parameters": {
      "language": "nodejs",
      "database": "dynamodb"
    }
  }'
```

### 3. Server Processing

```javascript
// 1. Load template
const template = templates.get('create-user-endpoint');
// template.content = entire markdown file

// 2. Substitute parameters
let prompt = template.content;
prompt = prompt.replace(/{{language}}/g, 'nodejs');
prompt = prompt.replace(/{{database}}/g, 'dynamodb');

// 3. Send to Kiro CLI
kiroSession.sendMessage(prompt);
```

### 4. Kiro CLI Receives

```markdown
# Create User Endpoint

## Role
You are an expert backend developer.

## Constraints
- Use nodejs best practices
- Include error handling
- Follow RESTful conventions

## Intent
Create a POST /api/users endpoint.

## Instructions
1. Create endpoint handler in nodejs
2. Validate input (name, email)
3. Save to dynamodb
4. Return JSON response

## Expected Output
```json
{
  "code": "...generated code...",
  "language": "nodejs",
  "database": "dynamodb"
}
```
```

### 5. Kiro CLI Generates

Kiro reads the markdown structure and generates output according to:
- Role (context)
- Constraints (requirements)
- Intent (goal)
- Instructions (steps)
- Expected Output (format/schema)

### 6. Server Returns

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

### 1. **Simple**
- No complex parsing
- No section extraction
- Just parameter substitution

### 2. **Flexible**
- Any markdown structure works
- Kiro CLI interprets it
- Add any sections you want

### 3. **Maintainable**
- Edit markdown directly
- No code changes needed
- Version control friendly

### 4. **Powerful**
- Full markdown capabilities
- Code blocks
- Lists, tables, etc.

## Template Structure (Recommended)

```markdown
# Template Title

## Parameters
- List parameters here (for documentation)

## Role
Define AI's expertise and context

## Constraints
List requirements and limitations

## Intent
Clear goal statement

## Instructions
Step-by-step actions with {{parameters}}

## Expected Output
Define output format (can include JSON schema)

## Command (Optional)
Test commands to execute

## Success Criteria (Optional)
Validation metrics
```

## Parameter Substitution

### Simple Variables
```markdown
Create {{language}} endpoint
```
→ `Create nodejs endpoint`

### Conditionals
```markdown
{{#if auth}}
Add authentication middleware
{{/if}}
```
→ Shows content if `auth` parameter is truthy

## Output Schema

Specify expected output format in template:

```markdown
## Expected Output

Return JSON with this structure:
```json
{
  "code": "string - generated code",
  "language": "string - programming language",
  "tests": "string - test code (optional)",
  "documentation": "string - API docs (optional)"
}
```
```

Kiro CLI will follow this schema when generating output.

## Complete Example

**Template:** `templates/api-endpoint.md`
```markdown
# API Endpoint Generator

## Parameters
- `method` (required): GET | POST | PUT | DELETE
- `path` (required): endpoint path
- `language` (required): nodejs | python | go

## Role
You are an expert API developer.

## Constraints
- Use {{language}} best practices
- Include input validation
- Add error handling
- Follow REST conventions

## Intent
Create a {{method}} endpoint at {{path}}.

## Instructions
1. Create {{method}} handler for {{path}}
2. Add input validation
3. Implement business logic
4. Return appropriate response
5. Handle errors with proper status codes

## Expected Output
```json
{
  "endpoint": "string - endpoint code",
  "tests": "string - test code",
  "method": "{{method}}",
  "path": "{{path}}"
}
```
```

**Usage:**
```bash
curl -X POST http://localhost:8081/api/generate \
  -d '{
    "templateId": "api-endpoint",
    "parameters": {
      "method": "POST",
      "path": "/api/users",
      "language": "nodejs"
    }
  }'
```

**Result:**
Kiro CLI generates code following the template structure and returns JSON matching the schema.

## Advantages Over Parsing

| Approach | Complexity | Flexibility | Maintenance |
|----------|-----------|-------------|-------------|
| **Parse Markdown** | High | Low | Hard |
| **Send to Kiro** | Low | High | Easy |

**Why Send to Kiro is Better:**
- ✅ Kiro CLI already understands markdown
- ✅ No parsing code needed
- ✅ More flexible (any markdown structure)
- ✅ Easier to maintain
- ✅ Kiro can interpret context better
- ✅ Output schema enforcement by Kiro

## Summary

**Old Approach:**
```
Markdown → Parse → Extract Sections → Build Prompt → Kiro CLI
```

**New Approach:**
```
Markdown → Substitute Parameters → Kiro CLI
```

**Result:** Simpler, more flexible, easier to maintain! 🎉
