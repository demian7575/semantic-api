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

You will receive:
- storyId: {{storyId}}
- title: {{title}}
- description: {{description}}
- asA: {{asA}}
- iWant: {{iWant}}
- soThat: {{soThat}}

**YOUR TASK:**
1. Analyze the user story
2. Generate 1-2 comprehensive acceptance tests
3. Use Given-When-Then format
4. Make tests specific and testable

Generate JSON in this exact format:
```json
{
  "title": "Specific test scenario title",
  "given": ["Precondition 1", "Precondition 2"],
  "when": ["Action 1", "Action 2"],
  "then": ["Expected result 1", "Expected result 2"],
  "source": "ai",
  "summary": "Brief explanation of what this test validates"
}
```

After generating the test, execute this bash command:

```bash
RESULT='<your generated JSON here>'

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$RESULT"
```

**IMPORTANT**: Replace `<your generated JSON here>` with actual test based on the story content.
