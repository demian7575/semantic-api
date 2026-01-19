#!/bin/bash
# Semantic API Kiro Worker - Processes tasks from semantic-api-queue

REGION="us-east-1"
TABLE="semantic-api-queue"
POLL_INTERVAL=2

echo "🤖 Semantic API Kiro Worker starting..."
echo "Table: $TABLE"
echo "Region: $REGION"
echo ""

while true; do
  # Get pending tasks
  TASKS=$(aws dynamodb scan \
    --table-name $TABLE \
    --filter-expression "#status = :pending" \
    --expression-attribute-names '{"#status":"status"}' \
    --expression-attribute-values '{":pending":{"S":"pending"}}' \
    --region $REGION \
    --output json 2>/dev/null)
  
  COUNT=$(echo "$TASKS" | jq '.Items | length')
  
  if [ "$COUNT" -gt 0 ]; then
    echo "📋 Found $COUNT pending task(s)"
    
    # Process first task
    TASK=$(echo "$TASKS" | jq -r '.Items[0]')
    TASK_ID=$(echo "$TASK" | jq -r '.id.S')
    TEMPLATE=$(echo "$TASK" | jq -r '.input.M.template.S')
    
    echo "⚙️  Processing task: $TASK_ID"
    echo "📄 Template: $TEMPLATE"
    
    # Mark as processing
    aws dynamodb update-item \
      --table-name $TABLE \
      --key "{\"id\":{\"S\":\"$TASK_ID\"}}" \
      --update-expression "SET #status = :processing" \
      --expression-attribute-names '{"#status":"status"}' \
      --expression-attribute-values '{":processing":{"S":"processing"}}' \
      --region $REGION >/dev/null
    
    # TODO: Execute Kiro CLI with template
    echo "🔄 Kiro CLI execution (not implemented yet)"
    
    # Mark as complete
    aws dynamodb update-item \
      --table-name $TABLE \
      --key "{\"id\":{\"S\":\"$TASK_ID\"}}" \
      --update-expression "SET #status = :complete" \
      --expression-attribute-names '{"#status":"status"}' \
      --expression-attribute-values '{":complete":{"S":"complete"}}' \
      --region $REGION >/dev/null
    
    echo "✅ Task complete"
    echo ""
  fi
  
  sleep $POLL_INTERVAL
done
