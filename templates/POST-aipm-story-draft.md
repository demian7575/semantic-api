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

You will receive:
- featureDescription: {{featureDescription}}
- parentId: {{parentId}}
- components: {{components}}

**YOUR TASK:**
1. Analyze the feature description
2. Create a well-structured user story following INVEST principles
3. Generate 1-2 realistic acceptance tests with Given-When-Then format
4. Assign appropriate story points (1, 2, 3, 5, 8, 13)
5. Return ONLY valid JSON matching the Output Schema

Think about:
- Who is the user? (asA)
- What do they want to do? (iWant)
- Why do they want it? (soThat)
- What are the key scenarios to test?

After generating the story, execute this bash command to return the result:

```bash
RESULT='<your generated JSON here>'

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$RESULT"
```

**IMPORTANT**: Replace `<your generated JSON here>` with the actual JSON you generated. Do not return template placeholders.
