#!/bin/bash
set -e

echo "🔗 Setting up GitHub repository..."

# Check if git is initialized
if [ ! -d .git ]; then
  echo "Initializing git repository..."
  git init
  git branch -M main
fi

# Prompt for GitHub username and repo name
read -p "Enter your GitHub username: " GITHUB_USER
read -p "Enter repository name [kiro-api-project]: " REPO_NAME
REPO_NAME=${REPO_NAME:-kiro-api-project}

# Add remote
REMOTE_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo "Adding remote: $REMOTE_URL"

if git remote | grep -q origin; then
  git remote set-url origin $REMOTE_URL
else
  git remote add origin $REMOTE_URL
fi

# Stage and commit
echo "Staging files..."
git add .

if git diff --cached --quiet; then
  echo "No changes to commit"
else
  git commit -m "Initial commit: Kiro API project"
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ GitHub setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Go to: https://github.com/$GITHUB_USER/$REPO_NAME/settings/secrets/actions"
echo "2. Add these secrets:"
echo "   - EC2_HOST (your EC2 IP address)"
echo "   - EC2_USER (usually 'ec2-user')"
echo "   - EC2_SSH_KEY (your private SSH key content)"
echo ""
echo "3. Enable GitHub Actions:"
echo "   https://github.com/$GITHUB_USER/$REPO_NAME/actions"
echo ""
echo "See GITHUB_SETUP.md for detailed instructions."
