# Markdown Template Format

## Overview

Templates are now **markdown files** with structured sections that define role, constraints, intent, and instructions for Kiro CLI.

## Template Structure

```markdown
# Template Title

## Metadata
- **ID**: unique-template-id
- **Category**: endpoint | function | test
- **Version**: 1.0

## Parameters
- `param1` (required): value1 | value2 | value3
- `param2` (optional): any string value
- `param3` (required): number value

## Role
You are an expert [role description].

## Constraints
- Constraint 1
- Constraint 2
- Constraint 3

## Intent
Clear statement of what needs to be accomplished.

## Instructions
1. Step 1 with {{param1}}
2. Step 2 with {{param2}}
3. {{#if param3}}Conditional step{{/if}}
4. Final step

## Expected Output
Description of expected output format and structure.

## Command
```bash
# Command to execute after generation
curl -X POST http://localhost:4000/api/endpoint \
  -d '{"key": "value"}'
```

## Success Criteria
- Criterion 1
- Criterion 2
```

## Section Descriptions

### Metadata (Required)
- **ID**: Unique identifier (kebab-case)
- **Category**: Template category
- **Version**: Template version

### Parameters (Required)
Define input parameters:
```markdown
- `paramName` (required|optional): allowed values | separated | by | pipes
```

### Role (Required)
Define the AI's role and expertise:
```markdown
You are an expert backend developer with 10 years of experience in REST API design.
```

### Constraints (Required)
List requirements and limitations:
```markdown
- Use modern ES6+ syntax
- Include error handling
- Follow RESTful conventions
- Maximum response time: 200ms
```

### Intent (Required)
Clear statement of the goal:
```markdown
Create a POST /api/users endpoint that validates input and stores user data in DynamoDB.
```

### Instructions (Required)
Step-by-step instructions:
```markdown
1. Create endpoint handler
2. Validate input: {{param1}}
3. {{#if auth}}Add authentication{{/if}}
4. Save to database
5. Return response
```

**Supports:**
- Variables: `{{paramName}}`
- Conditionals: `{{#if paramName}}...{{/if}}`

### Expected Output (Optional)
Describe the expected result:
```markdown
Generate production-ready Node.js code with:
- Express route handler
- Input validation using Joi
- DynamoDB integration
- Comprehensive error handling
```

### Command (Optional)
Command to execute after generation:
```markdown
```bash
curl -X POST http://localhost:4000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'
```
```

### Success Criteria (Optional)
Define success metrics:
```markdown
- Code compiles without errors
- All tests pass
- Response time < 200ms
- Proper error handling
```

## Complete Example

```markdown
# Create User Endpoint

## Metadata
- **ID**: create-user-endpoint
- **Category**: endpoint
- **Version**: 1.0

## Parameters
- `language` (required): nodejs | python | go
- `database` (required): dynamodb | postgres | mongodb
- `auth` (optional): true | false

## Role
You are an expert backend developer specializing in REST API development with 10+ years of experience.

## Constraints
- Use modern best practices for {{language}}
- Include comprehensive error handling
- Follow RESTful conventions
- Use async/await for asynchronous operations
- Include input validation
- Return proper HTTP status codes (200, 400, 401, 500)
- Add detailed code comments

## Intent
Create a POST /api/users endpoint that accepts user data, validates it, stores it in {{database}}, and returns the created user with proper error handling.

## Instructions
1. Create endpoint handler for POST /api/users
2. Accept request body with fields: name (string), email (string), age (number)
3. Validate input:
   - name: required, minimum 2 characters
   - email: required, valid email format
   - age: optional, must be positive number if provided
4. {{#if auth}}Implement JWT authentication middleware{{/if}}
5. Generate unique user ID
6. Save user to {{database}} with timestamp
7. Return response with status 201: { id, name, email, createdAt }
8. Handle errors:
   - 400 for validation errors with detailed message
   - {{#if auth}}401 for authentication failures{{/if}}
   - 500 for database or server errors

## Expected Output
Generate complete, production-ready {{language}} code including:
- Endpoint route handler
- Input validation logic
- {{database}} connection and operations
- {{#if auth}}JWT authentication middleware{{/if}}
- Error handling with proper status codes
- Response formatting
- Inline code comments explaining key sections

Format as a single, executable code file.

## Command
```bash
# Test the generated endpoint
curl -X POST http://localhost:4000/api/users \
  -H "Content-Type: application/json" \
  {{#if auth}}-H "Authorization: Bearer <your-jwt-token>" \{{/if}}
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }'

# Expected response (201 Created):
# {
#   "id": "user-123",
#   "name": "John Doe",
#   "email": "john@example.com",
#   "createdAt": "2026-01-19T16:17:00Z"
# }
```

## Success Criteria
- Code compiles and runs without errors
- Input validation catches invalid data
- Database operations succeed
- Proper HTTP status codes returned
- {{#if auth}}Authentication is enforced{{/if}}
- Error messages are clear and helpful
- Code follows language-specific best practices
```

## How It Works

### 1. Template Processing
```
Markdown Template → Parser → Structured Data → Prompt Builder → Kiro CLI
```

### 2. Parameter Substitution
```markdown
Template: "Create {{method}} endpoint in {{language}}"
Parameters: { method: "POST", language: "nodejs" }
Result: "Create POST endpoint in nodejs"
```

### 3. Conditional Logic
```markdown
Template: "{{#if auth}}Add authentication{{/if}}"
Parameters: { auth: true }
Result: "Add authentication"

Parameters: { auth: false }
Result: "" (empty)
```

### 4. Prompt Construction
The system builds a comprehensive prompt:
```
[Role]
You are an expert backend developer...

[Constraints]
- Use modern best practices
- Include error handling
...

[Task]
Create a POST /api/users endpoint...

[Instructions]
1. Create endpoint handler
2. Validate input
...

[Expected Output]
Generate production-ready code...
```

## Benefits

### 1. **Human-Readable**
- Easy to read and edit
- Clear structure
- Self-documenting

### 2. **Intent-Driven**
- Explicit role definition
- Clear constraints
- Specific instructions

### 3. **Flexible**
- Support variables
- Conditional logic
- Extensible sections

### 4. **Executable**
- Includes test commands
- Success criteria
- Validation steps

### 5. **Maintainable**
- Version control friendly
- Easy to review
- Simple to update

## Best Practices

1. **Clear Role Definition**
   - Be specific about expertise
   - Define experience level
   - Mention relevant technologies

2. **Explicit Constraints**
   - List all requirements
   - Specify limitations
   - Define quality standards

3. **Detailed Instructions**
   - Break into small steps
   - Use parameters
   - Include conditionals

4. **Testable Commands**
   - Provide curl examples
   - Include expected responses
   - Show error cases

5. **Success Criteria**
   - Measurable outcomes
   - Clear validation
   - Quality metrics

## Migration from JSON

**Old (JSON):**
```json
{
  "id": "create-user",
  "prompt": "Create user endpoint in {{language}}"
}
```

**New (Markdown):**
```markdown
# Create User

## Metadata
- **ID**: create-user

## Parameters
- `language` (required): nodejs | python

## Role
You are an expert backend developer.

## Intent
Create a user endpoint.

## Instructions
1. Create endpoint in {{language}}
2. Add validation
3. Return response
```

---

**See also:**
- [create-user-endpoint.md](../templates/create-user-endpoint.md) - Complete example
- [TEMPLATE_QUICK_START.md](TEMPLATE_QUICK_START.md) - Quick start guide
