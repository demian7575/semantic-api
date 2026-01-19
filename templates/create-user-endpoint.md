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
You are an expert backend developer specializing in REST API development.

## Constraints
- Use modern best practices
- Include error handling
- Follow RESTful conventions
- Use async/await for nodejs
- Include input validation
- Return proper HTTP status codes

## Intent
Create a POST /api/users endpoint that creates a new user in the database with proper validation and error handling.

## Instructions

1. Create endpoint handler for POST /api/users
2. Accept request body: `{ name: string, email: string, age: number }`
3. Validate input:
   - name: required, min 2 chars
   - email: required, valid email format
   - age: optional, must be positive number
4. {{#if auth}}Add JWT authentication middleware{{/if}}
5. Save to {{database}}
6. Return response: `{ id: string, name: string, email: string, createdAt: timestamp }`
7. Handle errors:
   - 400 for validation errors
   - 401 for auth errors (if auth enabled)
   - 500 for server errors

## Expected Output

Generate complete {{language}} code with:
- Endpoint handler function
- Input validation logic
- {{database}} integration
- {{#if auth}}Authentication middleware{{/if}}
- Error handling
- Response formatting

Format as production-ready code with comments.

## Command
```bash
# After code generation, test with:
curl -X POST http://localhost:4000/api/users \
  -H "Content-Type: application/json" \
  {{#if auth}}-H "Authorization: Bearer <token>" \{{/if}}
  -d '{"name":"John Doe","email":"john@example.com","age":30}'
```

## Success Criteria
- Code compiles/runs without errors
- Validation works correctly
- Database operations succeed
- Proper error responses
- {{#if auth}}Authentication enforced{{/if}}
