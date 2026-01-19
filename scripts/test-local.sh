#!/bin/bash

echo "🧪 Testing Semantic API Server Locally"
echo "========================================"

# Start server in background
echo "Starting server on port 8082..."
cd /repo/ebaejun/tools/aws/semantic-api
node src/semantic-api-server.js &
SERVER_PID=$!

# Wait for server to start
sleep 2

# Test health endpoint
echo ""
echo "Testing /health endpoint..."
curl -s http://localhost:8082/health | jq '.' || echo "❌ Health check failed"

# Test template endpoint
echo ""
echo "Testing POST /api/users endpoint..."
curl -s -X POST http://localhost:8082/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}' | jq '.' || echo "❌ API test failed"

# Cleanup
echo ""
echo "Stopping server..."
kill $SERVER_PID 2>/dev/null

echo ""
echo "✅ Local tests complete!"
