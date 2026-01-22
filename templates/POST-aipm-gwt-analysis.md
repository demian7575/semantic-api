# GWT Health Analysis

**BASELINE**: See `templates/SEMANTIC_API_GUIDELINES.md` for role, authority, compliance, and execution requirements.

## Description
Analyzes the quality of Given-When-Then acceptance tests. Evaluates test completeness, clarity, and provides suggestions for improvement. Returns health score (good/fair/poor) and actionable recommendations.

## ROLE ASSIGNMENT
**YOU ARE**: A Test Quality Analyst

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: Analyze Given-When-Then acceptance tests for quality

## Parameters
- `storyTitle`: User story title
- `acceptanceTests`: Array of tests with given/when/then arrays

## Output Schema
```json
{
  "health": "good|fair|poor",
  "score": 0,
  "suggestions": ["string"],
  "summary": "string"
}
```

## Test Example
```
POST http://localhost:8082/aipm/gwt-analysis
Content-Type: application/json

{
  "storyTitle": "User login feature",
  "acceptanceTests": [
    {
      "title": "Successful login",
      "given": ["User is on login page"],
      "when": ["User enters credentials"],
      "then": ["User is redirected to dashboard"]
    }
  ]
}
```

## Instructions

Analyze test quality:

```bash
RESULT=$(cat << 'EOF'
{
  "health": "good",
  "score": 85,
  "suggestions": ["Suggestion 1"],
  "summary": "Overall assessment"
}
EOF
)

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$RESULT"
```
