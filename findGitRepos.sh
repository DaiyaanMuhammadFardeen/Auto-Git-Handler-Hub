#!/bin/sh

CACHE_DIR="$HOME/.cache/aghh"
REPO_LIST="$CACHE_DIR/repocache.txt"

# Make sure the cache directory exists
mkdir -p "$CACHE_DIR"

# Empty the list file
> "$REPO_LIST"

# Search for all directories named ".git"
find "$HOME" -type d -name ".git" 2>/dev/null | while read -r gitdir; do
    repo_path=$(dirname "$gitdir")
    echo "$repo_path" >> "$REPO_LIST"
done

echo "Found $(wc -l < "$REPO_LIST") repositories."
echo "List saved to $REPO_LIST"

