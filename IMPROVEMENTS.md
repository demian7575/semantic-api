# Intent-Driven API Design (Semantic API)

## Current Design Analysis

### ✅ Strengths

1. **Intent-Driven**
   - Clear role definition
   - Explicit constraints
   - Specific instructions
   - Success criteria

2. **Flexible**
   - Markdown format (human-readable)
   - Parameter substitution
   - Conditional logic
   - Extensible structure

3. **Executable**
   - Includes test commands
   - Validation steps
   - Expected outputs

### ⚠️ Potential Issues

1. **Template Parsing Complexity**
   - Markdown parsing can be fragile
   - Section detection relies on headers
   - Parameter extraction needs careful handling

2. **No Template Validation**
   - Missing sections not caught
   - Invalid parameter definitions
   - Malformed conditionals

3. **Command Execution Risk**
   - Arbitrary command execution
   - No sandboxing
   - Security concerns

4. **No Template Versioning**
   - Breaking changes not tracked
   - No migration path
   - Compatibility issues

## 🚀 Improvement Suggestions

### 1. Template Validation Schema

Add JSON Schema validation for parsed templates:

```json
{
  "type": "object",
  "required": ["id", "role", "intent", "instructions"],
  "properties": {
    "id": { "type": "string", "pattern": "^[a-z0-9-]+$" },
    "role": { "type": "string", "minLength": 10 },
    "constraints": { "type": "array", "minItems": 1 },
    "intent": { "type": "string", "minLength": 10 },
    "instructions": { "type": "array", "minItems": 1 },
    "parameters": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["name", "required"],
        "properties": {
          "name": { "type": "string" },
          "required": { "type": "boolean" },
          "enum": { "type": "array" }
        }
      }
    }
  }
}
```

### 2. Safe Command Execution

Instead of arbitrary commands, use structured actions:

```markdown
## Actions
- type: http_request
  method: POST
  url: http://localhost:4000/api/users
  headers:
    Content-Type: application/json
  body:
    name: "{{name}}"
    email: "{{email}}"
  
- type: validate_response
  status: 201
  schema:
    type: object
    required: [id, name, email]
```

### 3. Template Inheritance

Support template extension:

```markdown
# Create User Endpoint

## Extends
- base-rest-endpoint.md

## Override: Instructions
1. Validate email format
2. Check for duplicate email
3. Hash password
4. Save to database
```

### 4. Multi-Step Workflows

Support chained operations:

```markdown
## Workflow
1. Generate code (template: create-endpoint)
2. Generate tests (template: create-tests)
3. Generate docs (template: create-docs)
4. Execute: npm test
5. Execute: npm run deploy
```

### 5. Parameter Validation

Add parameter validation rules:

```markdown
## Parameters
- `email` (required): string
  - format: email
  - example: user@example.com
  
- `age` (optional): number
  - min: 0
  - max: 150
  - default: 18
  
- `language` (required): enum
  - values: [nodejs, python, go]
  - default: nodejs
```

### 6. Template Testing

Add test cases to templates:

```markdown
## Test Cases

### Test 1: Valid Input
- Input: { name: "John", email: "john@example.com" }
- Expected: 201 Created
- Response: { id: string, name: "John", email: "john@example.com" }

### Test 2: Invalid Email
- Input: { name: "John", email: "invalid" }
- Expected: 400 Bad Request
- Response: { error: "Invalid email format" }

### Test 3: Missing Name
- Input: { email: "john@example.com" }
- Expected: 400 Bad Request
- Response: { error: "Name is required" }
```

### 7. Template Composition

Support modular templates:

```markdown
## Includes
- validation/email-validation.md
- auth/jwt-middleware.md
- database/dynamodb-operations.md

## Instructions
1. {{include: validation/email-validation.md}}
2. {{include: auth/jwt-middleware.md}}
3. Save to database using {{include: database/dynamodb-operations.md}}
```

### 8. Environment-Specific Templates

Support different environments:

```markdown
## Environments

### Development
- database: localhost:5432
- auth: disabled
- logging: debug

### Production
- database: {{env.DB_HOST}}
- auth: required
- logging: error
```

### 9. Template Metrics

Track template usage and success:

```markdown
## Metrics
- usage_count: 0
- success_rate: 0%
- avg_execution_time: 0ms
- last_used: null
- created_by: user@example.com
- created_at: 2026-01-19
```

### 10. Interactive Parameters

Support dynamic parameter collection:

```markdown
## Parameters
- `database` (required): enum
  - values: [dynamodb, postgres, mongodb]
  - prompt: "Which database do you want to use?"
  - help: "DynamoDB is recommended for serverless applications"
  
- `auth` (optional): boolean
  - prompt: "Do you need authentication?"
  - default: true
  - if_true:
    - ask: `auth_type` (required): enum
      - values: [jwt, oauth, api-key]
```

## 🎯 Recommended Architecture

### Enhanced Template Structure

```markdown
# Template Title

## Metadata
- **ID**: unique-id
- **Version**: 1.0.0
- **Category**: endpoint
- **Tags**: [rest, crud, user]
- **Author**: team@example.com
- **Extends**: base-endpoint.md

## Parameters
- `param1` (required): type
  - validation: rules
  - default: value
  - prompt: "Question?"

## Role
Expert role definition

## Constraints
- Constraint list

## Intent
Clear goal statement

## Instructions
1. Step-by-step
2. With {{variables}}
3. {{#if condition}}Conditional{{/if}}

## Expected Output
Output description

## Actions
- Structured actions instead of raw commands

## Test Cases
- Test scenarios

## Success Criteria
- Measurable outcomes

## Metrics
- Usage tracking
```

### API Flow

```
1. Client → POST /api/generate
   {
     "templateId": "create-user-endpoint",
     "parameters": { "language": "nodejs", "database": "dynamodb" }
   }

2. Server:
   a. Load template (markdown)
   b. Validate template structure
   c. Validate parameters
   d. Substitute variables
   e. Build prompt
   f. Send to Kiro CLI
   g. Execute actions (if any)
   h. Validate output
   i. Return result

3. Client ← Response
   {
     "taskId": "task-123",
     "status": "completed",
     "result": "...generated code...",
     "actions": [
       {
         "type": "http_request",
         "status": "success",
         "response": {...}
       }
     ]
   }
```

## 🔒 Security Improvements

1. **Sandboxed Execution**
   - Run commands in isolated environment
   - Whitelist allowed commands
   - Timeout limits

2. **Template Signing**
   - Cryptographic signatures
   - Verify template integrity
   - Prevent tampering

3. **Parameter Sanitization**
   - Escape special characters
   - Validate against schema
   - Prevent injection attacks

4. **Rate Limiting**
   - Per-user limits
   - Per-template limits
   - Global rate limits

5. **Audit Logging**
   - Log all template usage
   - Track parameter values
   - Monitor for abuse

## 📊 Flexibility Enhancements

1. **Plugin System**
   - Custom parameter types
   - Custom validators
   - Custom actions

2. **Template Marketplace**
   - Share templates
   - Version control
   - Community ratings

3. **Visual Template Builder**
   - Drag-and-drop interface
   - Parameter wizard
   - Live preview

4. **AI-Assisted Templates**
   - Generate templates from examples
   - Suggest improvements
   - Auto-complete sections

5. **Multi-Language Support**
   - Templates in different languages
   - Localized prompts
   - Regional best practices

## 🎯 Stability Improvements

1. **Template Versioning**
   - Semantic versioning
   - Breaking change detection
   - Migration guides

2. **Backward Compatibility**
   - Support old template formats
   - Deprecation warnings
   - Automatic migration

3. **Error Recovery**
   - Retry failed operations
   - Fallback templates
   - Graceful degradation

4. **Health Monitoring**
   - Template success rates
   - Performance metrics
   - Error tracking

5. **Automated Testing**
   - Template validation tests
   - Integration tests
   - Performance tests

## 💡 Next Steps

### Phase 1: Core Improvements (Week 1-2)
- [ ] Add template validation schema
- [ ] Implement parameter validation
- [ ] Add template versioning
- [ ] Improve error handling

### Phase 2: Safety & Security (Week 3-4)
- [ ] Implement safe action execution
- [ ] Add parameter sanitization
- [ ] Implement rate limiting
- [ ] Add audit logging

### Phase 3: Advanced Features (Week 5-6)
- [ ] Template inheritance
- [ ] Multi-step workflows
- [ ] Template composition
- [ ] Test case support

### Phase 4: Ecosystem (Week 7-8)
- [ ] Template marketplace
- [ ] Visual builder
- [ ] Plugin system
- [ ] Documentation site

---

**Current Status**: ✅ Basic markdown templates working  
**Next Priority**: Template validation and parameter sanitization
