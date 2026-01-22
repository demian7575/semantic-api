# Template Generator

**BASELINE**: See templates/SEMANTIC_API_GUIDELINES.md

## Description
Generates a complete Semantic API template based on a feature idea. Creates template with proper structure including description, role, parameters, output schema, test example, and bash instructions.

## ROLE ASSIGNMENT
**YOU ARE**: A Semantic API template generator

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: Generate complete template files following Semantic API conventions

## Parameters
- `idea`: Feature description or API idea

## Output Schema
```json
{
  "filename": "METHOD-path.md",
  "content": "Complete template markdown content"
}
```

## Test Example
```
POST http://localhost:8082/generate-template
Content-Type: application/json

{
  "idea": "Get user profile information by user ID"
}
```

## Instructions

You will receive: {{idea}}

**YOUR TASK:**
1. Analyze the idea and determine appropriate HTTP method (GET/POST/PUT/DELETE)
2. Design the endpoint path
3. Identify required parameters
4. Create output schema
5. Write bash commands for execution
6. Generate complete template content

**Template Structure:**
- Title with description
- BASELINE reference
- Description section
- Role assignment
- Authority & responsibility
- Parameters list
- Output schema (JSON)
- Test example (HTTP request format)
- Instructions with bash commands calling callback endpoint

**IMPORTANT**: 
- Use callback pattern: `curl -X POST http://localhost:8082/callback/{{taskId}}`
- Include explicit instruction: "You MUST execute these bash commands using the execute_bash tool"
- Make bash commands concrete and executable

Generate JSON in this format:
```json
{
  "filename": "GET-users-profile.md",
  "content": "# User Profile Template\n\n**BASELINE**: See templates/SEMANTIC_API_GUIDELINES.md\n\n## Description\n..."
}
```

After generating, execute this bash command:

```bash
RESULT='<your generated JSON here>'

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$RESULT"
```

**IMPORTANT**: Replace `<your generated JSON here>` with the actual JSON containing filename and complete template content.
