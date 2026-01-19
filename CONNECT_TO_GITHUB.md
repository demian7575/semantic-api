# 🔗 Connect to GitHub - Quick Guide

## Option 1: Automated Setup (Recommended)

```bash
./scripts/setup-github.sh
```

This script will:
1. Initialize git repository
2. Prompt for your GitHub username and repo name
3. Add remote origin
4. Commit and push to GitHub
5. Show next steps for secrets configuration

## Option 2: Manual Setup

### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `kiro-api-project`
3. Description: "Kiro CLI API integration with AWS"
4. Public or Private (your choice)
5. Click "Create repository"

### Step 2: Connect Local Repository

```bash
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/kiro-api-project.git

# Rename branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

### Step 3: Configure GitHub Secrets

Required for automated deployment:

1. Go to: `Settings → Secrets and variables → Actions`
2. Click "New repository secret"
3. Add these three secrets:

| Secret Name | Value | How to Get |
|------------|-------|------------|
| `EC2_HOST` | Your EC2 IP | AWS Console → EC2 → Instance → Public IPv4 |
| `EC2_USER` | `ec2-user` | Default for Amazon Linux |
| `EC2_SSH_KEY` | Private key content | `cat ~/.ssh/your-key.pem` |

### Step 4: Verify Setup

```bash
# Check remote
git remote -v

# Should show:
# origin  https://github.com/YOUR_USERNAME/kiro-api-project.git (fetch)
# origin  https://github.com/YOUR_USERNAME/kiro-api-project.git (push)
```

## GitHub Actions Workflows

Two workflows are automatically configured:

### 1. CI Tests (`.github/workflows/test.yml`)
- **Triggers**: Pull requests, pushes to main
- **Actions**: Install deps → Run tests
- **Purpose**: Code quality checks

### 2. Deploy (`.github/workflows/deploy.yml`)
- **Triggers**: Push to main, manual trigger
- **Actions**: Test → Deploy to EC2 → Health check
- **Purpose**: Automated deployment

## Test Deployment

```bash
# Make a change
echo "# Test" >> README.md

# Commit and push
git add .
git commit -m "Test deployment"
git push

# Watch deployment
# Go to: https://github.com/YOUR_USERNAME/kiro-api-project/actions
```

## Troubleshooting

### "Permission denied (publickey)"
```bash
# Ensure SSH key is added to GitHub
cat ~/.ssh/id_rsa.pub
# Add to: https://github.com/settings/keys
```

### "Repository not found"
```bash
# Check remote URL
git remote -v

# Update if needed
git remote set-url origin https://github.com/YOUR_USERNAME/kiro-api-project.git
```

### Deployment fails
- Verify secrets are set correctly
- Check EC2 security group allows SSH
- Test manual deployment: `./scripts/deploy.sh`

## Next Steps

1. ✅ Repository connected to GitHub
2. ✅ Secrets configured
3. ✅ Workflows enabled
4. → Read [GITHUB_SETUP.md](GITHUB_SETUP.md) for advanced configuration
5. → Setup branch protection rules
6. → Configure notifications

---

**Need more details?** → [GITHUB_SETUP.md](GITHUB_SETUP.md)
