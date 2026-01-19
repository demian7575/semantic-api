#!/usr/bin/env node
// Persistent Kiro CLI Session Server
// Keeps one Kiro CLI process running and handles requests via HTTP

import http from 'http';
import { spawn } from 'child_process';
import { readFileSync } from 'fs';

const PORT = 9001;
let kiroProcess = null;
let currentPromptResolve = null;
let outputBuffer = '';
let isProcessing = false;

function startKiro() {
  console.log('Starting persistent Kiro CLI session...');
  kiroProcess = spawn('/home/ec2-user/.local/bin/kiro-cli', ['chat', '--trust-all-tools'], {
    stdio: ['pipe', 'pipe', 'pipe']
  });

  kiroProcess.stdout.on('data', (data) => {
    outputBuffer += data.toString();
  });

  kiroProcess.stderr.on('data', (data) => {
    console.error('Kiro stderr:', data.toString());
  });

  kiroProcess.on('exit', () => {
    console.log('Kiro CLI exited, restarting...');
    setTimeout(startKiro, 1000);
  });
}

async function sendPrompt(prompt) {
  if (isProcessing) {
    throw new Error('Already processing a request');
  }

  isProcessing = true;
  outputBuffer = '';

  return new Promise((resolve) => {
    currentPromptResolve = resolve;
    kiroProcess.stdin.write(prompt + '\n');

    // Wait for output to stabilize (no new output for 2 seconds)
    let lastOutputTime = Date.now();
    const checkInterval = setInterval(() => {
      if (Date.now() - lastOutputTime > 2000) {
        clearInterval(checkInterval);
        isProcessing = false;
        resolve(outputBuffer);
      }
    }, 500);

    // Update last output time when new data arrives
    const originalLength = outputBuffer.length;
    const watchInterval = setInterval(() => {
      if (outputBuffer.length > originalLength) {
        lastOutputTime = Date.now();
      }
    }, 100);

    setTimeout(() => {
      clearInterval(watchInterval);
      clearInterval(checkInterval);
      isProcessing = false;
      resolve(outputBuffer);
    }, 60000); // 60 second timeout
  });
}

// HTTP server
const server = http.createServer(async (req, res) => {
  if (req.method === 'POST' && req.url === '/execute') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const { prompt } = JSON.parse(body);
        const result = await sendPrompt(prompt);
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end(result);
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: error.message }));
      }
    });
  } else {
    res.writeHead(404);
    res.end();
  }
});

startKiro();
server.listen(PORT, () => {
  console.log(`Persistent Kiro CLI server running on port ${PORT}`);
});
