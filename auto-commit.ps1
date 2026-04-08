# Auto commit script for Windows PowerShell

# Get current date and time
$currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Generate random commit message
$commitMessages = @(
    "Update rules and skills",
    "Enhance project documentation",
    "Improve code quality",
    "Add new features",
    "Fix issues",
    "Optimize performance",
    "Update dependencies",
    "Refactor code structure",
    "Enhance user experience",
    "Improve documentation"
)

$randomMessage = $commitMessages | Get-Random
$commitMessage = "chore: $randomMessage - $currentDate"

# Add all changes to staging
git add .

# Commit with dynamic message
git commit -m "$commitMessage"

# Push to remote repository
git push origin main

# Output result
Write-Host "Commit completed with message: $commitMessage"
