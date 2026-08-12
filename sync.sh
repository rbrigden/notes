#!/bin/bash

# Exit on any error during configuration, but handle git commands gracefully
set -e

# Log file is managed by launchd plist, but let's print a header
echo "=== Notes Sync: $(date) ==="

# Define the repository path
REPO_DIR="/Users/monomoy/notes"

# Check if repo directory exists
if [ ! -d "$REPO_DIR" ]; then
    echo "Error: Directory $REPO_DIR does not exist."
    exit 1
fi

cd "$REPO_DIR"

# Ensure we have git executable in path
export PATH="/usr/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"

# Check if it's a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: $REPO_DIR is not a git repository."
    exit 1
fi

# Add all files (including new and deleted)
git add -A

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    # Commit changes
    COMMIT_MSG="Daily update: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Committing changes with message: '$COMMIT_MSG'"
    git commit -m "$COMMIT_MSG"
    
    # Push changes
    echo "Pushing to origin..."
    if git push origin main; then
        echo "Push successful."
    else
        echo "Error: Failed to push changes."
        exit 1
    fi
fi

echo "=== Notes Sync Completed ==="
