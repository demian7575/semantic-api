// Simple test without DynamoDB
import http from 'http';

console.log('🧪 Testing Template-Based API (Simple)');
console.log('======================================\n');

// Test URL mapping logic
function testMapping() {
  console.log('Test: URL to Template Mapping');
  
  const tests = [
    { method: 'POST', path: '/api/users', expected: 'templates/POST-api-users.md' },
    { method: 'GET', path: '/api/users', expected: 'templates/GET-api-users.md' },
    { method: 'PUT', path: '/api/users/123', expected: 'templates/PUT-api-users-123.md' },
    { method: 'DELETE', path: '/products', expected: 'templates/DELETE-products.md' },
  ];
  
  tests.forEach(test => {
    const template = `templates/${test.method}${test.path.replace(/\//g, '-')}.md`;
    const pass = template === test.expected;
    console.log(`  ${pass ? '✓' : '✗'} ${test.method} ${test.path}`);
    console.log(`    → ${template}`);
    if (!pass) console.log(`    Expected: ${test.expected}`);
  });
  
  console.log('');
}

// Test template files exist
function testTemplates() {
  console.log('Test: Template Files');
  import('fs').then(fs => {
    const templates = [
      'templates/POST-api-users.md',
      'templates/GET-api-users.md'
    ];
    
    templates.forEach(template => {
      const exists = fs.existsSync(template);
      console.log(`  ${exists ? '✓' : '✗'} ${template}`);
    });
    
    console.log('\n✅ Tests Complete!');
    console.log('\nTo test the full API:');
    console.log('1. Ensure DynamoDB table exists');
    console.log('2. Run: npm start');
    console.log('3. Run: ./scripts/test-api.sh');
  });
}

testMapping();
testTemplates();
