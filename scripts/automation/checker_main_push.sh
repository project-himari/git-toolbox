#!/bin/sh

# Get current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Block push to main
if [ "$current_branch" = "main" ]; then
  echo "Error: Direct push to 'main' branch is prohibited."
  echo "Use a feature branch and open a Pull Request."
  exit 1
fi

exit 0
