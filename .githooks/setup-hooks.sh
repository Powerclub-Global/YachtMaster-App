#!/bin/bash

# Setup Git Hooks for YachtMaster App
# Run this script to install the pre-commit hook

echo "🔧 Setting up Git hooks..."

# Get the git directory
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)

if [ -z "$GIT_DIR" ]; then
    echo "❌ Error: Not a git repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_DIR/hooks"

# Copy pre-commit hook
cp .githooks/pre-commit "$GIT_DIR/hooks/pre-commit"
chmod +x "$GIT_DIR/hooks/pre-commit"

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "The hook will now:"
echo "  🔐 Check for secrets (API keys, passwords)"
echo "  📁 Prevent forbidden files (.env, keystores)"
echo "  🖨️  Warn about print() statements"
echo "  🔍 Run Flutter analyze"
echo "  🧪 Run tests if test files changed"
echo ""
echo "To bypass the hook (NOT RECOMMENDED):"
echo "  git commit --no-verify"
echo ""
