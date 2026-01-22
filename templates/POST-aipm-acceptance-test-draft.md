# Acceptance Test Draft Generation

**BASELINE**: See `templates/SEMANTIC_API_GUIDELINES.md` for role, authority, compliance, and execution requirements.

## Description
Generates a Given-When-Then acceptance test based on a user story. Creates specific, measurable test scenarios that validate the story's acceptance criteria.

## ROLE ASSIGNMENT
**YOU ARE**: An Acceptance Test Writer

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: Generate Given-When-Then acceptance tests

## Parameters
- `storyTitle`: User story title
- `storyDescription`: User story description
- `asA`: User role
- `iWant`: User goal
- `soThat`: User benefit
- `idea`: Optional test idea or focus area
- `ordinal`: Test number

## Output Schema
```json
{
  "title": "string",
  "given": ["string"],
  "when": ["string"],
  "then": ["string"],
  "source": "ai",
  "summary": "string"
}
```

## Test Example
```
POST http://localhost:8082/aipm/acceptance-test-draft
Content-Type: application/json

{
  "storyTitle": "User login feature",
  "storyDescription": "Implement user authentication",
  "asA": "user",
  "iWant": "to login securely",
  "soThat": "I can access my account",
  "idea": "Test successful login",
  "ordinal": 1
}
```

## Instructions

Generate acceptance test based on the story:

```bash
RESULT=$(cat << 'EOF'
{
  "title": "Test title based on story",
  "given": ["Precondition 1"],
  "when": ["Action 1"],
  "then": ["Expected result 1"],
  "source": "ai",
  "summary": "Brief explanation"
}
EOF
)

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$RESULT"
```
