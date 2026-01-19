#!/bin/bash
# Semantic API Kiro Worker - Processes tasks from semantic-api-queue

REGION="us-east-1"
TABLE="semantic-api-queue"
POLL_INTERVAL=0.5

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
    PARAMS=$(echo "$TASK" | jq -r '.input.M.parameters.M')
    
    echo "⚙️  Processing task: $TASK_ID"
    echo "📄 Template: $TEMPLATE"
    
    # Create temp template with taskId injected
    TEMP_TEMPLATE="/tmp/template-$TASK_ID.md"
    sed "s/{{taskId}}/$TASK_ID/g" "$TEMPLATE" > "$TEMP_TEMPLATE"
    
    # Inject other parameters
    for key in $(echo "$PARAMS" | jq -r 'keys[]'); do
      value=$(echo "$PARAMS" | jq -r ".$key.S // .$key.N")
      sed -i "s/{{$key}}/$value/g" "$TEMP_TEMPLATE"
    done
    
    # Mark as processing
    aws dynamodb update-item \
      --table-name $TABLE \
      --key "{\"id\":{\"S\":\"$TASK_ID\"}}" \
      --update-expression "SET #status = :processing" \
      --expression-attribute-names '{"#status":"status"}' \
      --expression-attribute-values '{":processing":{"S":"processing"}}' \
      --region $REGION >/dev/null
    
    # Execute Kiro CLI directly
    echo "🔄 Executing Kiro CLI..."
    TEMPLATE_CONTENT=$(cat "$TEMP_TEMPLATE")
    
    echo "$TEMPLATE_CONTENT" | /home/ec2-user/.local/bin/kiro-cli chat --trust-all-tools --no-interactive >/dev/null 2>&1
    
    echo "✅ Task complete (callback handled response)"
    
    rm -f "$TEMP_TEMPLATE"
    echo ""
  fi
  
  sleep $POLL_INTERVAL
done
