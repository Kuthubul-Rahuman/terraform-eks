#!/bin/bash

# Define the patterns to be added to .gitignore
PATTERNS=".terraform.lock.hcl
.terraform/"

# Check if .gitignore exists; if not, create it
if [ ! -f .gitignore ]; then
  touch .gitignore
  echo ".gitignore file created."
fi

# Loop through each pattern and add it to .gitignore if not already present
for PATTERN in $PATTERNS; do
  if ! grep -q "^$PATTERN$" .gitignore; then
    echo "$PATTERN" >> .gitignore
    echo "Added $PATTERN to .gitignore."
  else
    echo "$PATTERN is already in .gitignore."
  fi
done

echo "Update complete."

