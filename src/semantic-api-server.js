#!/usr/bin/env node

import http from 'http';
import { existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, ScanCommand } from '@aws-sdk/lib-dynamodb';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const TEMPLATES_DIR = join(__dirname, '../templates');

const PORT = process.env.KIRO_API_PORT || 9000;
const QUEUE_TABLE = process.env.KIRO_QUEUE_TABLE || 'semantic-api-queue';

// AIPM DynamoDB tables (read-only)
const AIPM_STORIES_TABLE = 'aipm-backend-prod-stories';
const AIPM_TESTS_TABLE = 'aipm-backend-prod-acceptance-tests';

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const dynamodb = DynamoDBDocumentClient.from(client);

// Store pending requests waiting for callback
const pendingRequests = new Map();

// HTTP server
const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);

  // Direct DynamoDB read endpoint (no Kiro CLI needed)
  if (url.pathname === '/aipm/stories/direct' && req.method === 'GET') {
    const limit = parseInt(url.searchParams.get('limit') || '10');
    const status = url.searchParams.get('status');
    
    try {
      const { ScanCommand } = await import('@aws-sdk/lib-dynamodb');
      const params = {
        TableName: AIPM_STORIES_TABLE,
        Limit: limit
      };
      
      if (status) {
        params.FilterExpression = '#status = :status';
        params.ExpressionAttributeNames = { '#status': 'status' };
        params.ExpressionAttributeValues = { ':status': status };
      }
      
      const result = await dynamodb.send(new ScanCommand(params));
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ stories: result.Items || [] }));
    } catch (error) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: error.message }));
    }
    return;
  }

  // Health check
  if (url.pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy' }));
    return;
  }

  // Callback endpoint for Kiro CLI to post results
  if (url.pathname.startsWith('/callback/') && req.method === 'POST') {
    const taskId = url.pathname.split('/').pop();
    console.log(`Callback received for task: ${taskId}`);
    console.log(`Pending requests: ${Array.from(pendingRequests.keys()).join(', ')}`);
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const result = JSON.parse(body);
        console.log(`Callback data length: ${body.length}`);
        await dynamodb.send(new UpdateCommand({
          TableName: QUEUE_TABLE,
          Key: { id: taskId },
          UpdateExpression: 'SET #status = :complete, #result = :result',
          ExpressionAttributeNames: { '#status': 'status', '#result': 'result' },
          ExpressionAttributeValues: { ':complete': 'complete', ':result': JSON.stringify(result) }
        }));
        
        // Resolve pending request if exists
        if (pendingRequests.has(taskId)) {
          console.log(`Resolving pending request for ${taskId}`);
          const { res: pendingRes } = pendingRequests.get(taskId);
          pendingRes.writeHead(200, { 'Content-Type': 'application/json' });
          pendingRes.end(JSON.stringify(result));
          pendingRequests.delete(taskId);
        } else {
          console.log(`No pending request found for ${taskId}`);
        }
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: error.message }));
      }
    });
    return;
  }

  // Get task result
  if (url.pathname.startsWith('/task/') && req.method === 'GET') {
    const taskId = url.pathname.split('/').pop();
    try {
      const result = await dynamodb.send(new GetCommand({
        TableName: QUEUE_TABLE,
        Key: { id: taskId }
      }));
      if (!result.Item) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Task not found' }));
        return;
      }
      
      // Extract clean JSON from Kiro CLI output
      let cleanResult = result.Item;
      if (result.Item.result && typeof result.Item.result === 'string') {
        try {
          // Try to extract JSON from AWS CLI output
          const jsonMatch = result.Item.result.match(/\{[\s\S]*"Items"[\s\S]*\}/);
          if (jsonMatch) {
            const awsResult = JSON.parse(jsonMatch[0]);
            cleanResult = { ...result.Item, result: awsResult };
          }
        } catch (e) {
          // Keep original if parsing fails
        }
      }
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(cleanResult));
    } catch (error) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: error.message }));
    }
    return;
  }

  // Generic template-based endpoint
  // Map: METHOD /path/to/endpoint → templates/METHOD-path-to-endpoint.md
  const templateName = `${req.method}${url.pathname.replace(/\//g, '-')}.md`;
  const templatePath = join(TEMPLATES_DIR, templateName);
  
  console.log(`Request: ${req.method} ${url.pathname}`);
  console.log(`Template: ${templatePath}`);
  console.log(`Exists: ${existsSync(templatePath)}`);
  
  // Check if template exists
  if (!existsSync(templatePath)) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Requested resource not found' }));
    return;
  }

  let body = '';
  req.on('data', chunk => body += chunk);
  req.on('end', async () => {
    try {
      console.log(`Body: "${body}"`);
      console.log(`Query params:`, Object.fromEntries(url.searchParams));
      const parameters = body ? JSON.parse(body) : Object.fromEntries(url.searchParams);
      console.log(`Parameters:`, parameters);
      const taskId = `task-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

      const task = {
        id: taskId,
        status: 'pending',
        createdAt: Date.now(),
        input: { template: templatePath, parameters }
      };

      await dynamodb.send(new PutCommand({ TableName: QUEUE_TABLE, Item: task }));

      // Store pending request - callback will resolve it
      console.log(`Task created: ${taskId}, waiting for callback...`);
      pendingRequests.set(taskId, { res, createdAt: Date.now() });
      
      // Timeout after 90 seconds
      setTimeout(() => {
        if (pendingRequests.has(taskId)) {
          pendingRequests.delete(taskId);
          res.writeHead(202, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ 
            taskId, 
            status: 'timeout',
            message: 'Processing timeout, check /task/' + taskId 
          }));
        }
      }, 90000);
    } catch (error) {
      console.error(`Error:`, error);
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: error.message }));
    }
  });
});

server.listen(PORT, () => {
  console.log(`Kiro API server running on port ${PORT}`);
  console.log(`Template mapping: METHOD /path → templates/METHOD-path.md`);
});
