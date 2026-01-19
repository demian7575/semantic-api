#!/usr/bin/env node

import http from 'http';
import { spawn } from 'child_process';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, ScanCommand } from '@aws-sdk/lib-dynamodb';

const PORT = process.env.KIRO_API_PORT || 8081;
const QUEUE_TABLE = process.env.KIRO_QUEUE_TABLE || 'kiro-task-queue';
const SESSIONS_TABLE = process.env.KIRO_SESSIONS_TABLE || 'kiro-sessions';
const MAX_SESSIONS = parseInt(process.env.KIRO_MAX_SESSIONS || '5');

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const dynamodb = DynamoDBDocumentClient.from(client);

let activeSessions = new Map();
let taskQueue = [];
let processing = false;

// Kiro session manager
class KiroSession {
  constructor(sessionId) {
    this.sessionId = sessionId;
    this.process = null;
    this.lastActivity = Date.now();
    this.status = 'idle';
  }

  async start() {
    this.process = spawn('kiro-cli', ['chat'], {
      stdio: ['pipe', 'pipe', 'pipe']
    });
    
    this.status = 'active';
    await this.saveState();
    
    this.process.on('exit', () => {
      this.status = 'closed';
      activeSessions.delete(this.sessionId);
    });
  }

  async sendMessage(message) {
    return new Promise((resolve, reject) => {
      if (!this.process || this.status !== 'active') {
        return reject(new Error('Session not active'));
      }

      let output = '';
      const timeout = setTimeout(() => {
        reject(new Error('Kiro timeout'));
      }, 300000);

      this.process.stdout.on('data', (data) => {
        output += data.toString();
      });

      this.process.once('close', () => {
        clearTimeout(timeout);
        resolve(output);
      });

      this.process.stdin.write(message + '\n');
      this.lastActivity = Date.now();
    });
  }

  async saveState() {
    await dynamodb.send(new PutCommand({
      TableName: SESSIONS_TABLE,
      Item: {
        sessionId: this.sessionId,
        status: this.status,
        lastActivity: this.lastActivity,
        processId: this.process?.pid
      }
    }));
  }

  close() {
    if (this.process) {
      this.process.kill();
      this.process = null;
    }
    this.status = 'closed';
  }
}

// Task processor
async function processQueue() {
  if (processing || taskQueue.length === 0) return;
  
  processing = true;
  
  while (taskQueue.length > 0 && activeSessions.size < MAX_SESSIONS) {
    const task = taskQueue.shift();
    
    try {
      let session = activeSessions.get(task.sessionId);
      
      if (!session) {
        session = new KiroSession(task.sessionId || `session-${Date.now()}`);
        await session.start();
        activeSessions.set(session.sessionId, session);
      }

      await dynamodb.send(new UpdateCommand({
        TableName: QUEUE_TABLE,
        Key: { taskId: task.taskId },
        UpdateExpression: 'SET #status = :status, sessionId = :sessionId',
        ExpressionAttributeNames: { '#status': 'status' },
        ExpressionAttributeValues: {
          ':status': 'processing',
          ':sessionId': session.sessionId
        }
      }));

      const result = await session.sendMessage(task.prompt);

      await dynamodb.send(new UpdateCommand({
        TableName: QUEUE_TABLE,
        Key: { taskId: task.taskId },
        UpdateExpression: 'SET #status = :status, result = :result, completedAt = :completedAt',
        ExpressionAttributeNames: { '#status': 'status' },
        ExpressionAttributeValues: {
          ':status': 'completed',
          ':result': result,
          ':completedAt': Date.now()
        }
      }));
    } catch (error) {
      await dynamodb.send(new UpdateCommand({
        TableName: QUEUE_TABLE,
        Key: { taskId: task.taskId },
        UpdateExpression: 'SET #status = :status, error = :error',
        ExpressionAttributeNames: { '#status': 'status' },
        ExpressionAttributeValues: {
          ':status': 'failed',
          ':error': error.message
        }
      }));
    }
  }
  
  processing = false;
}

// HTTP server
const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);

  // Health check
  if (url.pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'healthy',
      activeSessions: activeSessions.size,
      queueLength: taskQueue.length,
      uptime: process.uptime()
    }));
    return;
  }

  // Submit chat task
  if (url.pathname === '/api/chat' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const { message, sessionId } = JSON.parse(body);
        const taskId = `task-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

        const task = {
          taskId,
          status: 'pending',
          createdAt: Date.now(),
          prompt: message,
          sessionId: sessionId || null
        };

        await dynamodb.send(new PutCommand({
          TableName: QUEUE_TABLE,
          Item: task
        }));

        taskQueue.push(task);
        processQueue();

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ taskId, status: 'pending' }));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: error.message }));
      }
    });
    return;
  }

  // Get task status
  if (url.pathname.startsWith('/api/task/') && req.method === 'GET') {
    const taskId = url.pathname.split('/').pop();
    
    try {
      const result = await dynamodb.send(new GetCommand({
        TableName: QUEUE_TABLE,
        Key: { taskId }
      }));

      if (!result.Item) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Task not found' }));
        return;
      }

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(result.Item));
    } catch (error) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: error.message }));
    }
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not found' }));
});

// Cleanup idle sessions
setInterval(() => {
  const now = Date.now();
  for (const [sessionId, session] of activeSessions) {
    if (now - session.lastActivity > 600000) { // 10 minutes
      session.close();
      activeSessions.delete(sessionId);
    }
  }
}, 60000);

// Load pending tasks on startup
async function loadPendingTasks() {
  const result = await dynamodb.send(new ScanCommand({
    TableName: QUEUE_TABLE,
    FilterExpression: '#status = :status',
    ExpressionAttributeNames: { '#status': 'status' },
    ExpressionAttributeValues: { ':status': 'pending' }
  }));

  taskQueue = result.Items || [];
  processQueue();
}

server.listen(PORT, () => {
  console.log(`Kiro API server running on port ${PORT}`);
  loadPendingTasks();
});
