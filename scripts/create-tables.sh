#!/bin/bash
set -e

REGION="us-east-1"

echo "🗄️  Creating DynamoDB tables for Semantic API..."

# Task queue table
aws dynamodb create-table \
  --table-name semantic-api-queue \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

echo "✅ Created: semantic-api-queue"

# Sessions table
aws dynamodb create-table \
  --table-name semantic-api-sessions \
  --attribute-definitions AttributeName=sessionId,AttributeType=S \
  --key-schema AttributeName=sessionId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

echo "✅ Created: semantic-api-sessions"

echo ""
echo "✅ All tables created!"
aws dynamodb list-tables --region $REGION | jq '.TableNames[] | select(contains("semantic"))'
