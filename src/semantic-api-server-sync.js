#!/usr/bin/env node

import http from 'http';
import { existsSync, readFile, readdir, writeFile, unlink } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { spawn } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const TEMPLATES_DIR = join(__dirname, '../templates');
const PORT = process.env.KIRO_API_PORT || 8082;
const MAX_CONCURRENT = 5;

let activeCount = 0;
const pendingRequests = new Map();

// Execute Kiro CLI (fire and forget - callback will handle response)
function execKiroCLI(templateContent) {
  const kiro = spawn('/home/ec2-user/.local/bin/kiro-cli', [
    'chat',
    '--trust-all-tools',
    '--no-interactive'
  ]);

  kiro.stdin.write(templateContent);
  kiro.stdin.end();
  
  // Log errors but don't wait for completion
  kiro.stderr.on('data', (data) => {
    console.error('Kiro CLI error:', data.toString());
  });
}

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

  // Health check
  if (url.pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
      status: 'healthy',
      activeRequests: activeCount,
      pendingCallbacks: pendingRequests.size
    }));
    return;
  }

  // Callback endpoint
  if (url.pathname.startsWith('/callback/') && req.method === 'POST') {
    const taskId = url.pathname.split('/').pop();
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const result = JSON.parse(body);
        
        if (pendingRequests.has(taskId)) {
          const { res: pendingRes } = pendingRequests.get(taskId);
          pendingRes.writeHead(200, { 'Content-Type': 'application/json' });
          pendingRes.end(JSON.stringify(result));
          pendingRequests.delete(taskId);
          activeCount--;
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

  // Serve index.html
  if (url.pathname === '/' && req.method === 'GET') {
    const indexPath = join(__dirname, '../public/index.html');
    readFile(indexPath, 'utf8', (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end('Not found');
      } else {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(data);
      }
    });
    return;
  }

  // List templates
  if (url.pathname === '/templates' && req.method === 'GET') {
    readdir(TEMPLATES_DIR, (err, files) => {
      if (err) {
        res.writeHead(500);
        res.end(JSON.stringify({ error: 'Failed to read templates' }));
      } else {
        const templates = files.filter(f => f.endsWith('.md'));
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ templates }));
      }
    });
    return;
  }

  // Get template content
  if (url.pathname.startsWith('/template/') && req.method === 'GET') {
    const templateName = url.pathname.split('/').pop();
    const templatePath = join(TEMPLATES_DIR, templateName);
    readFile(templatePath, 'utf8', (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end('Template not found');
      } else {
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end(data);
      }
    });
    return;
  }

  // Save/Update template
  if (url.pathname.startsWith('/template/') && req.method === 'PUT') {
    const templateName = url.pathname.split('/').pop();
    if (!templateName.endsWith('.md')) {
      res.writeHead(400);
      res.end('Template name must end with .md');
      return;
    }
    const templatePath = join(TEMPLATES_DIR, templateName);
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      writeFile(templatePath, body, 'utf8', (err) => {
        if (err) {
          res.writeHead(500);
          res.end(JSON.stringify({ error: 'Failed to save template' }));
        } else {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ success: true }));
        }
      });
    });
    return;
  }

  // Delete template
  if (url.pathname.startsWith('/template/') && req.method === 'DELETE') {
    const templateName = url.pathname.split('/').pop();
    const templatePath = join(TEMPLATES_DIR, templateName);
    unlink(templatePath, (err) => {
      if (err) {
        res.writeHead(500);
        res.end(JSON.stringify({ error: 'Failed to delete template' }));
      } else {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true }));
      }
    });
    return;
  }

  // Generate template using AI
  if (url.pathname === '/generate-template' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const { idea } = JSON.parse(body);
      const taskId = `gen-${Date.now()}`;
      
      const prompt = `Generate a Semantic API template based on this idea: "${idea}"

Create a complete template file with:
1. Appropriate METHOD-path.md filename
2. Description section
3. Role assignment
4. Parameters
5. Output schema (JSON)
6. Test example
7. Instructions with bash commands that call the callback endpoint

Return ONLY valid JSON in this format:
{
  "filename": "METHOD-path.md",
  "content": "# Template Title\\n\\n**BASELINE**: See templates/SEMANTIC_API_GUIDELINES.md\\n\\n## Description\\n...full template content..."
}

Execute this bash command to return the result:

RESULT='<your generated JSON here>'

curl -X POST http://localhost:8082/callback/${taskId} \\
  -H "Content-Type: application/json" \\
  -d "$RESULT"`;

      pendingRequests.set(taskId, { res, timeout: setTimeout(() => {
        if (pendingRequests.has(taskId)) {
          pendingRequests.delete(taskId);
          res.writeHead(504, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Request timeout' }));
          activeCount--;
        }
      }, 90000) });

      activeCount++;
      execKiroCLI(prompt);
    });
    return;
  }

  // Check concurrent limit
  if (activeCount >= MAX_CONCURRENT) {
    res.writeHead(503, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Server busy, try again later' }));
    return;
  }

  // Generic template-based endpoint
  const templateName = `${req.method}${url.pathname.replace(/\//g, '-')}.md`;
  const templatePath = join(TEMPLATES_DIR, templateName);
  
  if (!existsSync(templatePath)) {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Template not found' }));
    return;
  }

  let body = '';
  req.on('data', chunk => body += chunk);
  req.on('end', async () => {
    try {
      const parameters = body ? JSON.parse(body) : Object.fromEntries(url.searchParams);
      const taskId = `task-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

      // Read and inject parameters into template
      readFile(templatePath, 'utf8', (err, templateContent) => {
        if (err) {
          res.writeHead(500, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Failed to read template' }));
          return;
        }

        // Inject taskId and parameters
        let content = templateContent.replace(/\{\{taskId\}\}/g, taskId);
        for (const [key, value] of Object.entries(parameters)) {
          content = content.replace(new RegExp(`\\{\\{${key}\\}\\}`, 'g'), value);
        }

        // Store pending request (no taskId exposed to client)
        activeCount++;
        pendingRequests.set(taskId, { res, createdAt: Date.now() });

        // Execute Kiro CLI (callback will handle response)
        execKiroCLI(content);

        // Timeout after 90 seconds
        setTimeout(() => {
          if (pendingRequests.has(taskId)) {
            pendingRequests.delete(taskId);
            activeCount--;
            res.writeHead(504, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: 'Request timeout' }));
          }
        }, 90000);
      });
    } catch (error) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: error.message }));
    }
  });
});

server.listen(PORT, () => {
  console.log(`Semantic API server running on port ${PORT}`);
  console.log(`Max concurrent requests: ${MAX_CONCURRENT}`);
  console.log(`Using callback pattern for responses`);
});
