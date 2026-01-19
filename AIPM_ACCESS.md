# AIPM DynamoDB Access

Semantic API has **read-only** access to AIPM DynamoDB tables:

## Tables

- `aipm-backend-prod-stories` - User stories
- `aipm-backend-prod-acceptance-tests` - Acceptance tests

## Usage in Templates

Templates can reference AIPM data by specifying the table name in the template instructions.

### Example: GET-aipm-stories.md

```markdown
## Instructions
1. Connect to DynamoDB table: aipm-backend-prod-stories in us-east-1
2. Use ScanCommand to retrieve stories
3. Return results as JSON
```

## Access Pattern

- Semantic API **writes** to: `semantic-api-queue` (task queue)
- Semantic API **reads** from: AIPM tables (data source)
- Kiro worker processes tasks and generates code based on AIPM data

## Security

EC2 instance must have IAM role with:
- Read access to `aipm-backend-prod-*` tables
- Read/Write access to `semantic-api-*` tables
