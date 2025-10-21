# Auto-format and commit script for EdBindings
# This script formats code and automatically commits the changes

param(
    [string]$CommitMessage = "Auto-format code with dotnet format"
)

Write-Host "Auto-Format and Commit for EdBindings" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if we're in a git repository
if (!(Test-Path ".git")) {
    Write-Host "ERROR: Not in a git repository!" -ForegroundColor Red
    exit 1
}

# Check if there are uncommitted changes
$status = git status --porcelain 2>$null
if ($status) {
    Write-Host "WARNING: You have uncommitted changes. Please commit or stash them first." -ForegroundColor Yellow
    Write-Host "Uncommitted files:" -ForegroundColor Yellow
    git status --short
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Run code formatter
Write-Host "Formatting code..." -ForegroundColor Yellow
& "$PSScriptRoot\format-code.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Code formatting failed!" -ForegroundColor Red
    exit 1
}

# Check if formatting made any changes
$changes = git diff --name-only 2>$null
if (!$changes) {
    Write-Host "INFO: No formatting changes were needed." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "The following files were formatted:" -ForegroundColor Yellow
$changes | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }

# Stage all changes
Write-Host ""
Write-Host "Staging formatted files..." -ForegroundColor Yellow
git add .

# Commit the changes
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m $CommitMessage

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS: Code formatting committed!" -ForegroundColor Green
    Write-Host "Commit message: $CommitMessage" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "TIP: Don't forget to push your changes:" -ForegroundColor Yellow
    Write-Host "  git push" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: Failed to commit changes!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
