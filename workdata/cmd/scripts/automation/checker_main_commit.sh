#!/bin/sh

# Get current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Prevent committing directly to main
if [ "$current_branch" = "main" ]; then
  echo "Error: Direct commit to 'main' branch is prohibited."
  echo "Please switch to a feature branch."
  exit 1
fi

exit 0
