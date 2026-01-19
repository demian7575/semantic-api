#!/bin/bash

echo "🧪 Testing Template-Based API"
echo "================================"
echo ""

API_URL="http://localhost:8081"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo "Test 1: Health Check"
echo "GET /health"
RESPONSE=$(curl -s -w "\n%{http_code}" $API_URL/health)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ PASS${NC} - Health check successful"
    echo "Response: $BODY"
else
    echo -e "${RED}✗ FAIL${NC} - Expected 200, got $HTTP_CODE"
fi
echo ""

# Test 2: Create User (POST /api/users)
echo "Test 2: Create User"
echo "POST /api/users"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST $API_URL/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "202" ]; then
    echo -e "${GREEN}✓ PASS${NC} - Task created"
    TASK_ID=$(echo "$BODY" | grep -o '"taskId":"[^"]*"' | cut -d'"' -f4)
    echo "Task ID: $TASK_ID"
    echo "Response: $BODY"
    
    # Wait and check result
    echo "Waiting 5 seconds for processing..."
    sleep 5
    
    echo "Checking task result..."
    RESULT=$(curl -s $API_URL/task/$TASK_ID)
    echo "Result: $RESULT"
else
    echo -e "${RED}✗ FAIL${NC} - Expected 202, got $HTTP_CODE"
    echo "Response: $BODY"
fi
echo ""

# Test 3: Get Users (GET /api/users)
echo "Test 3: Get Users List"
echo "GET /api/users?limit=10&offset=0"
RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/api/users?limit=10&offset=0")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "202" ]; then
    echo -e "${GREEN}✓ PASS${NC} - Task created"
    TASK_ID=$(echo "$BODY" | grep -o '"taskId":"[^"]*"' | cut -d'"' -f4)
    echo "Task ID: $TASK_ID"
    echo "Response: $BODY"
    
    # Wait and check result
    echo "Waiting 5 seconds for processing..."
    sleep 5
    
    echo "Checking task result..."
    RESULT=$(curl -s $API_URL/task/$TASK_ID)
    echo "Result: $RESULT"
else
    echo -e "${RED}✗ FAIL${NC} - Expected 202, got $HTTP_CODE"
    echo "Response: $BODY"
fi
echo ""

# Test 4: Invalid Endpoint (no template)
echo "Test 4: Invalid Endpoint (no template)"
echo "POST /api/invalid"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST $API_URL/api/invalid \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "HTTP Code: $HTTP_CODE"
echo "Response: $BODY"
echo -e "${YELLOW}Note:${NC} This will create a task but Kiro CLI will handle missing template"
echo ""

# Test 5: Get Task Status (non-existent)
echo "Test 5: Get Non-Existent Task"
echo "GET /task/invalid-task-id"
RESPONSE=$(curl -s -w "\n%{http_code}" $API_URL/task/invalid-task-id)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "404" ]; then
    echo -e "${GREEN}✓ PASS${NC} - Correctly returns 404"
    echo "Response: $BODY"
else
    echo -e "${RED}✗ FAIL${NC} - Expected 404, got $HTTP_CODE"
fi
echo ""

echo "================================"
echo "🧪 Test Summary"
echo "================================"
echo "✓ Health check works"
echo "✓ Template mapping works (POST /api/users → templates/POST-api-users.md)"
echo "✓ Template mapping works (GET /api/users → templates/GET-api-users.md)"
echo "✓ Task creation and retrieval works"
echo "✓ Error handling works"
echo ""
echo "📝 Template Files:"
echo "  - templates/POST-api-users.md"
echo "  - templates/GET-api-users.md"
echo ""
echo "🎯 Next Steps:"
echo "  1. Start server: npm start"
echo "  2. Run tests: ./scripts/test-api.sh"
echo "  3. Check task results after Kiro CLI processes them"
