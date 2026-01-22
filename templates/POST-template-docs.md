# Template Documentation Parser

**BASELINE**: See templates/SEMANTIC_API_GUIDELINES.md

## Description
Parses a template file and extracts documentation information including endpoint, description, role, parameters, and test example.

## ROLE ASSIGNMENT
**YOU ARE**: A template documentation parser

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: Parse template markdown and extract structured information

## Parameters
- `templateName`: Template filename (e.g., GET-weather.md)
- `templateContent`: Full template markdown content

## Output Schema
```json
{
  "endpoint": "GET /weather",
  "description": "Fetches weather information",
  "role": "Weather data fetcher",
  "parameters": ["city"],
  "testExample": "GET http://localhost:8082/weather?city=Seoul"
}
```

## Test Example
```
POST http://localhost:8082/template-docs
Content-Type: application/json

{
  "templateName": "GET-weather.md",
  "templateContent": "# Weather Template\n\n## Description\n..."
}
```

## Instructions

You will receive:
- templateName: {{templateName}}
- templateContent: {{templateContent}}

**YOUR TASK:**
1. Extract HTTP method and path from filename
2. Find Description section content
3. Find Role (YOU ARE) content
4. Extract all {{parameters}} from template
5. Find Test Example section

Execute this bash command:

```bash
RESULT='{"endpoint":"GET /weather","description":"Fetches weather","role":"Weather fetcher","parameters":["city"],"testExample":"GET http://..."}'

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$RESULT"
```

**IMPORTANT**: Generate actual parsed data based on the template content provided.
