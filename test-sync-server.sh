#!/bin/bash
# Test synchronous semantic-api-server

echo "🧪 Testing Semantic API (Synchronous)"
echo ""

# Start server in background
echo "Starting server..."
node src/semantic-api-server-sync.js &
SERVER_PID=$!
sleep 2

# Health check
echo "1. Health check..."
curl -s http://localhost:8082/health | jq .
echo ""

# List templates
echo "2. List templates..."
curl -s http://localhost:8082/templates | jq .
echo ""

# Test weather endpoint (synchronous - waits for result)
echo "3. Test GET /weather?city=Seoul (waiting for result)..."
curl -s -X GET "http://localhost:8082/weather?city=Seoul" | jq .
echo ""

echo "4. Test POST /aipm/invest-analysis..."
curl -s -X POST http://localhost:8082/aipm/invest-analysis \
  -H "Content-Type: application/json" \
  -d '{
    "storyId": 123,
    "title": "User login feature",
    "description": "Implement user authentication",
    "asA": "user",
    "iWant": "to login securely",
    "soThat": "I can access my account"
  }' | jq .
echo ""

# Cleanup
echo "Stopping server..."
kill $SERVER_PID
echo "✅ Test complete"
