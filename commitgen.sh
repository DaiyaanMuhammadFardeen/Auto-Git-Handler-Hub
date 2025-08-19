#!/bin/bash
# Smart commit each file individually with GPT2

# If argument given, use it as repo root. Else fallback to pwd.
if [ -n "$1" ]; then
    REPO_ROOT="$1"
else
    REPO_ROOT=$(pwd)
fi

# Save current directory
CUR_DIR=$(pwd)

# Check if valid git repo
cd "$REPO_ROOT" || { echo "[ERROR] Cannot cd into $REPO_ROOT"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[ERROR] Not inside a git repository: $REPO_ROOT"
    cd "$CUR_DIR"
    exit 1
fi
# Stage all changes first
git add -A
# Get staged files
FILES=$(git diff --cached --name-only)

if [ -z "$FILES" ]; then
    echo "[ERROR] No staged files to commit."
    cd "$CUR_DIR"
    exit 1
fi

# Run Python commit generator
python3 ~/Desktop/Projects/Auto-Git-Handler-Hub/generate_commit.py $FILES

# Return to original directory
cd "$CUR_DIR"
