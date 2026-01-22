# Weather Temperature Template

**BASELINE**: See `templates/SEMANTIC_API_GUIDELINES.md` for role, authority, compliance, and execution requirements.

## Description
Fetches current weather information for a specified city using the wttr.in API. Returns temperature in both Celsius and Fahrenheit along with weather conditions.

## ROLE ASSIGNMENT
**YOU ARE**: A weather data fetcher

## AUTHORITY & RESPONSIBILITY
**YOUR AUTHORITY**: Fetch current temperature using wttr.in API

## Parameters
- `city`: City name (e.g., Seoul, Tokyo, London)

## Output Schema
```json
{
  "city": "string",
  "temp_c": "string",
  "temp_f": "string",
  "weather": "string"
}
```

## Test Example
```
GET http://localhost:8082/weather?city=Seoul
```

## Instructions

```bash
WEATHER=$(curl -s "wttr.in/{{city}}?format=j1" | jq -c '{city: "{{city}}", temp_c: .current_condition[0].temp_C, temp_f: .current_condition[0].temp_F, weather: .current_condition[0].weatherDesc[0].value}')

curl -X POST http://localhost:8082/callback/{{taskId}} \
  -H "Content-Type: application/json" \
  -d "$WEATHER"
```
