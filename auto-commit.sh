#!/bin/bash

# Auto commit script for Linux/macOS

# Get current date and time
current_date=$(date "%Y-%m-%d %H:%M:%S")

# Generate random commit message
commit_messages=(
    "Update rules and skills"
    "Enhance project documentation"
    "Improve code quality"
    "Add new features"
    "Fix issues"
    "Optimize performance"
    "Update dependencies"
    "Refactor code structure"
    "Enhance user experience"
    "Improve documentation"
)

random_index=$((RANDOM % ${#commit_messages[@]}))
random_message=${commit_messages[$random_index]}
commit_message="chore: $random_message - $current_date"

# Add all changes to staging
git add .

# Commit with dynamic message
git commit -m "$commit_message"

# Push to remote repository
git push origin main

# Output result
echo "Commit completed with message: $commit_message"
