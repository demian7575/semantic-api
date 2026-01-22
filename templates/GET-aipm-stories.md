# DynamoDB Reader Template

**BASELINE**: See `templates/SEMANTIC_API_GUIDELINES.md` for role, authority, compliance, and execution requirements.

## Description
Reads a user story from the AIPM DynamoDB table by story ID. Returns the complete story item including all attributes.

## ROLE ASSIGNMENT
**YOU ARE**: A DynamoDB reader

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: Read DynamoDB table following provided specifications

## Parameters
- `id`: Story ID number

## Output Schema
DynamoDB Item format (varies by table schema)

## Test Example
```
GET http://localhost:8082/aipm/stories?id=123
```

## Instructions

```bash
STORY=$(aws dynamodb get-item \
  --table-name aipm-backend-prod-stories \
  --key '{"id":{"N":"{{id}}"}}' \
  --region us-east-1 \
  --output json | jq -c '.Item')

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$STORY"
```
