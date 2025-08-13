#!/bin/bash
# Automatically generate and commit a message using GPT2
# Works from anywhere in any git repository

# Save current directory
CUR_DIR=$(pwd)

# Find the nearest git repo root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "[ERROR] Not inside a git repository."
    exit 1
fi

cd "$REPO_ROOT"

# Save staged diff to temporary file
TEMP_DIFF=$(mktemp)
git diff --cached > "$TEMP_DIFF"

# Call Python script (adjust path to your script as needed)
COMMIT_MSG=$(python3 ~/Desktop/Projects/Auto-Git-Handler-Hub/generate_commit.py "$TEMP_DIFF")

# Commit with generated message
git commit -m "$COMMIT_MSG -GPT2"

# Clean up
rm -f "$TEMP_DIFF"

# Return to original directory
cd "$CUR_DIR"

