# Get Users List

## Parameters
- `limit` (optional): number - Maximum number of users to return (default: 10)
- `offset` (optional): number - Number of users to skip (default: 0)
- `sort` (optional): string - Sort field (name, email, createdAt)

## Role
You are an expert backend developer.

## Constraints
- Use pagination
- Support sorting
- Return array of users
- Include total count

## Intent
Retrieve a paginated list of users with optional sorting.

## Instructions
1. Parse query parameters: limit={{limit}}, offset={{offset}}, sort={{sort}}
2. Apply pagination (limit, offset)
3. Apply sorting if specified
4. Return array of users
5. Include metadata (total, limit, offset)

## Expected Output
```json
{
  "users": [
    {
      "id": "uuid",
      "name": "string",
      "email": "string",
      "createdAt": "timestamp"
    }
  ],
  "total": 100,
  "limit": {{limit}},
  "offset": {{offset}}
}
```

## Success Criteria
- Pagination works correctly
- Sorting is applied
- Metadata is accurate
