# Create User

## Parameters
- `name` (required): string - User's full name
- `email` (required): string - User's email address
- `age` (optional): number - User's age

## Role
You are an expert backend developer specializing in REST API development.

## Constraints
- Use modern JavaScript ES6+ syntax
- Include input validation
- Follow RESTful conventions
- Return proper HTTP status codes
- Include error handling

## Intent
Create a new user endpoint that validates input, generates a unique ID, and returns the created user object.

## Instructions
1. Validate input parameters:
   - name: {{name}} (required, min 2 characters)
   - email: {{email}} (required, valid email format)
   - age: {{age}} (optional, must be positive number)
2. Generate unique user ID (UUID format)
3. Create user object with validated data
4. Add timestamp (createdAt)
5. Return user object with 201 status

## Expected Output
```json
{
  "id": "uuid-string",
  "name": "{{name}}",
  "email": "{{email}}",
  "age": {{age}},
  "createdAt": "ISO-8601-timestamp"
}
```

## Success Criteria
- Input validation works correctly
- Unique ID is generated
- Timestamp is in ISO-8601 format
- Response matches expected schema
