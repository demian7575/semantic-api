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
    
    # Execute Kiro CLI via persistent session
    echo "🔄 Executing Kiro CLI..."
    LOG_FILE="/tmp/kiro-cli-live.log"
    
    # Create prompt that tells Kiro to read the template
    PROMPT_FILE="/tmp/prompt-$TASK_ID.txt"
    echo "Read and follow the template file: $TEMP_TEMPLATE" > "$PROMPT_FILE"
    echo "" >> "$PROMPT_FILE"
    echo "Execute the template instructions exactly as written." >> "$PROMPT_FILE"
    
    # Send to persistent Kiro CLI session
    PROMPT=$(cat "$PROMPT_FILE")
    RESULT=$(curl -s -X POST http://localhost:9001/execute \
      -H "Content-Type: application/json" \
      -d "{\"prompt\": $(echo "$PROMPT" | jq -Rs '.')}")
    
    echo "[$(date -Iseconds)] [Task-$TASK_ID] Kiro CLI execution complete" >> "$LOG_FILE"
    echo "$RESULT" >> "$LOG_FILE"
    
    rm -f "$PROMPT_FILE" "$TEMP_TEMPLATE"
    
    # Check if callback was successful (don't overwrite callback data)
    TASK_STATUS=$(aws dynamodb get-item \
      --table-name $TABLE \
      --key "{\"id\":{\"S\":\"$TASK_ID\"}}" \
      --region $REGION \
      --output json | jq -r '.Item.status.S')
    
    if [ "$TASK_STATUS" = "complete" ]; then
      echo "✅ Task already completed by callback"
    else
      # Save result only if callback didn't complete it
      RESULT_JSON=$(echo "$RESULT" | jq -Rs '.')
      aws dynamodb update-item \
        --table-name $TABLE \
        --key "{\"id\":{\"S\":\"$TASK_ID\"}}" \
        --update-expression "SET #status = :complete, #result = :result" \
        --expression-attribute-names '{"#status":"status","#result":"result"}' \
        --expression-attribute-values "{\":complete\":{\"S\":\"complete\"},\":result\":{\"S\":$RESULT_JSON}}" \
        --region $REGION >/dev/null
      
      echo "✅ Task complete"
    fi
    echo ""
  fi
  
  sleep $POLL_INTERVAL
done
