#!/bin/bash
# GitHub CLI Authentication Script
# This script logs in a user via GitHub CLI (gh)

# Check if GitHub CLI is installed
if ! command -v gh &>/dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it first via your package manager."
    exit 1
fi

echo "Starting GitHub CLI authentication..."
echo "--------------------------------------"
echo "This will log you in to GitHub using the GitHub CLI."
echo "Follow the prompts in your terminal."

# Check if user is already authenticated
if gh auth status &>/dev/null; then
    echo "You are already logged in to GitHub!"
    echo "Current authentication status:"
    gh auth status
    echo ""
    read -p "Do you want to log in with a different account? (y/N): " confirm
    confirm=${confirm,,} # lowercase
    if [[ "$confirm" != "y" ]]; then
        exit 0
    else
        echo "Logging out..."
        gh auth logout -y
    fi
fi

# Start authentication
echo ""
echo "Choose login method:"
echo "1) Login via web browser (recommended)"
echo "2) Login via token (manual)"
read -p "Select option [1-2]: " method

case "$method" in
    1)
        echo "Opening web browser for GitHub authentication..."
        gh auth login -w
        ;;
    2)
        echo "Please create a personal access token (PAT) with repo access if needed."
        echo "Visit: https://github.com/settings/tokens"
        read -p "Enter your GitHub Personal Access Token: " token
        echo ""
        echo "Authenticating using token..."
        echo "$token" | gh auth login --with-token
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

# Verify authentication
echo ""
if gh auth status &>/dev/null; then
    echo "✅ GitHub authentication successful!"
    gh auth status
else
    echo "❌ GitHub authentication failed!"
fi
