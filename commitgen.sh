#!/bin/bash
# Get staged changes in diff format
git diff --cached > diff.txt

# Pass diff to Python model and get message
commit_msg=$(python generate_commit.py diff.txt)

# Commit with generated message
#
git commit -m "$commit_msg - by GPT2"

rm -rf diff.txt
