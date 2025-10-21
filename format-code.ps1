# Format Code Script for EdBindings
# This script formats all C# code in the solution according to .editorconfig rules

param(
    [switch]$Check,  # Only check formatting without making changes
    [switch]$Verbose # Show detailed output
)

Write-Host "Code Formatter for EdBindings" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Check if dotnet is available
if (!(Get-Command "dotnet" -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: .NET CLI not found. Please install .NET 8.0 SDK." -ForegroundColor Red
    exit 1
}

# Get the solution directory
$SolutionDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $SolutionDir

try {
    Write-Host "Working directory: $SolutionDir" -ForegroundColor Yellow

    if ($Check) {
        Write-Host "Checking code formatting..." -ForegroundColor Yellow

        if ($Verbose) {
            $result = dotnet format --verify-no-changes --verbosity diagnostic
        } else {
            $result = dotnet format --verify-no-changes --verbosity minimal 2>&1
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: All code is properly formatted!" -ForegroundColor Green
        } else {
            Write-Host "ERROR: Code formatting issues found:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Yellow
            Write-Host ""
            Write-Host "TIP: Run this script without -Check flag to auto-format the code." -ForegroundColor Cyan
            exit 1
        }
    } else {
        Write-Host "Formatting code..." -ForegroundColor Yellow

        if ($Verbose) {
            dotnet format --verbosity diagnostic
        } else {
            dotnet format --verbosity minimal
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Code formatting completed successfully!" -ForegroundColor Green

            # Check if any files were changed
            $changes = git diff --name-only 2>$null
            if ($changes) {
                Write-Host ""
                Write-Host "The following files were formatted:" -ForegroundColor Yellow
                $changes | ForEach-Object { Write-Host "   - $_" -ForegroundColor Cyan }
                Write-Host ""
                Write-Host "TIP: Do not forget to commit these changes!" -ForegroundColor Green
            } else {
                Write-Host "INFO: No files needed formatting." -ForegroundColor Yellow
            }
        } else {
            Write-Host "ERROR: Code formatting failed!" -ForegroundColor Red
            exit 1
        }
    }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
