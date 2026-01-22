# INVEST Analysis

**BASELINE**: See `templates/SEMANTIC_API_GUIDELINES.md` for role, authority, compliance, and execution requirements.

## Description
Analyzes user stories against INVEST principles (Independent, Negotiable, Valuable, Estimable, Small, Testable). Provides quality score, identifies weaknesses, and suggests improvements to make stories more effective.

## ROLE ASSIGNMENT
**YOU ARE**: An INVEST Principles Analyst

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: Analyze user stories against INVEST principles

## Parameters
- `storyId`: Story ID
- `title`: Story title
- `description`: Story description
- `asA`: User role
- `iWant`: User goal
- `soThat`: User benefit

## INVEST Principles
Independent, Negotiable, Valuable, Estimable, Small, Testable

## Output Schema
```json
{
  "storyId": 0,
  "summary": "string",
  "score": 0,
  "warnings": [
    {
      "criterion": "string",
      "message": "string",
      "suggestion": "string"
    }
  ],
  "strengths": ["string"],
  "source": "ai",
  "model": "kiro-cli"
}
```

## Test Example
```
POST http://localhost:8082/aipm/invest-analysis
Content-Type: application/json

{
  "storyId": 123,
  "title": "User login feature",
  "description": "Implement user authentication",
  "asA": "user",
  "iWant": "to login securely",
  "soThat": "I can access my account"
}
```

## Instructions

Analyze the story against INVEST principles and generate JSON result:

```bash
RESULT=$(cat << 'EOF'
{
  "storyId": {{storyId}},
  "summary": "Analysis summary here",
  "score": 85,
  "warnings": [],
  "strengths": ["Clear value proposition"],
  "source": "ai",
  "model": "kiro-cli"
}
EOF
)

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$RESULT"
```
