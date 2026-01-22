# User Story Generation Template

**BASELINE**: See `templates/SEMANTIC_API_GUIDELINES.md` for role, authority, compliance, and execution requirements.

## Description
Generates a complete user story following INVEST principles based on a feature description. Creates story with As a/I want/So that format, assigns story points, and includes 1-2 acceptance tests with Given-When-Then scenarios.

## ROLE ASSIGNMENT
**YOU ARE**: A User Story Writer

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: Generate user stories following INVEST principles

## Parameters
- `featureDescription`: Feature to implement
- `parentId`: Parent story ID (or null)
- `components`: Component array

## INVEST Principles
Independent, Negotiable, Valuable, Estimable, Small, Testable

## Output Schema
```json
{
  "title": "string",
  "description": "string",
  "asA": "string",
  "iWant": "string",
  "soThat": "string",
  "components": ["string"],
  "storyPoint": 0,
  "assigneeEmail": "",
  "parentId": null,
  "acceptWarnings": true,
  "acceptanceTests": [
    {
      "title": "string",
      "given": ["string"],
      "when": ["string"],
      "then": ["string"],
      "status": "Draft"
    }
  ]
}
```

## Test Example
```
POST http://localhost:8082/aipm/story-draft
Content-Type: application/json

{
  "featureDescription": "User authentication with email and password",
  "parentId": null,
  "components": ["frontend", "backend"]
}
```

## Instructions

Generate user story with acceptance tests:

```bash
RESULT=$(cat << 'EOF'
{
  "title": "Story title",
  "description": "Detailed description",
  "asA": "User persona",
  "iWant": "User goal",
  "soThat": "User benefit",
  "components": ["frontend", "backend"],
  "storyPoint": 5,
  "assigneeEmail": "",
  "parentId": null,
  "acceptWarnings": true,
  "acceptanceTests": [{
    "title": "Test title",
    "given": ["precondition"],
    "when": ["action"],
    "then": ["expected result"],
    "status": "Draft"
  }]
}
EOF
)

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$RESULT"
```
