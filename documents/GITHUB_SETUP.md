# GitHub Setup Guide

## 1. Create GitHub Repository

```bash
# On GitHub.com, create a new repository named "kiro-api-project"
# Then connect this local repository:

git remote add origin https://github.com/YOUR_USERNAME/kiro-api-project.git
git branch -M main
git add .
git commit -m "Initial commit: Kiro API project"
git push -u origin main
```

## 2. Configure GitHub Secrets

Go to: `Settings → Secrets and variables → Actions → New repository secret`

Add these secrets:

| Secret Name | Description | Example |
|------------|-------------|---------|
| `EC2_HOST` | EC2 public IP or hostname | `44.220.45.57` |
| `EC2_USER` | SSH user (usually ec2-user) | `ec2-user` |
| `EC2_SSH_KEY` | Private SSH key content | `-----BEGIN RSA PRIVATE KEY-----...` |

### Getting SSH Key Content

```bash
# Display your SSH key
cat ~/.ssh/your-key.pem

# Copy the entire output including:
# -----BEGIN RSA PRIVATE KEY-----
# ... key content ...
# -----END RSA PRIVATE KEY-----
```

## 3. GitHub Actions Workflows

Two workflows are configured:

### CI Tests (`.github/workflows/test.yml`)
- Runs on: Pull requests and pushes to main
- Actions: Install dependencies, run tests
- Purpose: Ensure code quality

### Deploy (`.github/workflows/deploy.yml`)
- Runs on: Push to main or manual trigger
- Actions: Test → Deploy to EC2 → Health check
- Purpose: Automated deployment

## 4. Manual Deployment Trigger

```bash
# Go to: Actions → Deploy to Production → Run workflow
# Or push to main branch
git push origin main
```

## 5. Branch Protection (Recommended)

Go to: `Settings → Branches → Add rule`

Configure:
- Branch name pattern: `main`
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
  - Select: `test`
- ✅ Require branches to be up to date before merging

## 6. Verify Setup

```bash
# Check remote
git remote -v

# Check workflows
ls -la .github/workflows/

# Test deployment
git add .
git commit -m "Test deployment"
git push origin main

# Monitor in GitHub Actions tab
```

## Quick Commands

```bash
# Initial setup
git init
git remote add origin https://github.com/YOUR_USERNAME/kiro-api-project.git
git branch -M main
git add .
git commit -m "Initial commit"
git push -u origin main

# Regular workflow
git add .
git commit -m "Your message"
git push

# Create feature branch
git checkout -b feature/new-feature
git push -u origin feature/new-feature
```

## Troubleshooting

### SSH Key Issues
```bash
# Ensure key has correct permissions
chmod 600 ~/.ssh/your-key.pem

# Test SSH connection
ssh -i ~/.ssh/your-key.pem ec2-user@YOUR_EC2_IP
```

### Deployment Fails
- Check GitHub Actions logs
- Verify secrets are set correctly
- Ensure EC2 security group allows SSH from GitHub IPs
- Test manual deployment: `./scripts/deploy.sh`

### Tests Fail
```bash
# Run tests locally
npm test

# Check test output
npm test -- --verbose
```
