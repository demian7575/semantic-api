import { test } from 'node:test';
import { strict as assert } from 'node:assert';

test('Kiro API - Health Check', async () => {
  const response = await fetch('http://localhost:8081/health');
  const data = await response.json();
  
  assert.equal(response.status, 200);
  assert.equal(data.status, 'healthy');
  assert.ok(typeof data.activeSessions === 'number');
  assert.ok(typeof data.queueLength === 'number');
});

test('Kiro API - Submit Chat Task', async () => {
  const response = await fetch('http://localhost:8081/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: 'Hello Kiro' })
  });
  
  const data = await response.json();
  
  assert.equal(response.status, 200);
  assert.ok(data.taskId);
  assert.equal(data.status, 'pending');
});

test('Kiro API - Get Task Status', async () => {
  // First create a task
  const createResponse = await fetch('http://localhost:8081/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: 'Test task' })
  });
  
  const { taskId } = await createResponse.json();
  
  // Then get its status
  const statusResponse = await fetch(`http://localhost:8081/api/task/${taskId}`);
  const data = await statusResponse.json();
  
  assert.equal(statusResponse.status, 200);
  assert.equal(data.taskId, taskId);
  assert.ok(['pending', 'processing', 'completed', 'failed'].includes(data.status));
});
