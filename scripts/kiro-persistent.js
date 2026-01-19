#!/usr/bin/env node
// Persistent Kiro CLI Session Server
// Keeps one Kiro CLI process running and handles requests via HTTP

import http from 'http';
import { spawn } from 'child_process';
import { readFileSync } from 'fs';

const PORT = 9001;
let kiroProcess = null;
const requestQueue = [];

function startKiro() {
  console.log('Starting persistent Kiro CLI session...');
  kiroProcess = spawn('/home/ec2-user/.local/bin/kiro-cli', ['chat', '--trust-all-tools', '--no-interactive'], {
    stdio: ['pipe', 'ignore', 'pipe']
  });

  kiroProcess.stderr.on('data', (data) => {
    console.error('Kiro stderr:', data.toString());
  });

  kiroProcess.on('exit', () => {
    console.log('Kiro CLI exited, restarting...');
    setTimeout(startKiro, 1000);
  });
}

function sendPrompt(prompt) {
  kiroProcess.stdin.write(prompt + '\n');
}

// HTTP server
const server = http.createServer(async (req, res) => {
  if (req.method === 'POST' && req.url === '/execute') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const { prompt } = JSON.parse(body);
        sendPrompt(prompt);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true }));
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
