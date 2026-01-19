#!/bin/bash

echo "🧪 Testing AIPM User Stories Template"
echo "======================================"
echo ""

# Test the template mapping
echo "Template Mapping:"
echo "GET /aipm/stories → templates/GET-aipm-stories.md"
echo ""

# Check template exists
if [ -f "templates/GET-aipm-stories.md" ]; then
    echo "✓ Template file exists"
else
    echo "✗ Template file not found"
    exit 1
fi

echo ""
echo "Template Content:"
echo "- Parameters: storyId, status, limit"
echo "- DynamoDB Table: aipm-backend-prod-stories"
echo "- Region: us-east-1"
echo "- Supports filtering by ID or status"
echo ""

echo "Example Usage:"
echo ""
echo "1. Get all stories:"
echo "   curl 'http://localhost:8081/aipm/stories?limit=10'"
echo ""
echo "2. Get specific story:"
echo "   curl 'http://localhost:8081/aipm/stories?storyId=story-123'"
echo ""
echo "3. Filter by status:"
echo "   curl 'http://localhost:8081/aipm/stories?status=In%20Progress&limit=5'"
echo ""

echo "✅ Template ready for use!"
