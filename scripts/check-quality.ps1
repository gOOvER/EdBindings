# Local Code Quality Check Script for EdBindings
# This script runs the same checks as the CI pipeline locally

param(
    [switch]$SkipTests,
    [switch]$SkipSecurity,
    [switch]$SkipFormatting,
    [switch]$Verbose,
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Colors for output
$Colors = @{
    Success = "Green"
    Warning = "Yellow" 
    Error = "Red"
    Info = "Cyan"
    Header = "Magenta"
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    
    if ($Colors.ContainsKey($Color)) {
        Write-Host $Message -ForegroundColor $Colors[$Color] -NoNewline:$NoNewline
    } else {
        Write-Host $Message -NoNewline:$NoNewline
    }
}

function Write-Header {
    param([string]$Title)
    
    Write-Host ""
    Write-ColorOutput "=" * 70 -Color "Header"
    Write-ColorOutput " $Title" -Color "Header"
    Write-ColorOutput "=" * 70 -Color "Header"
    Write-Host ""
}

function Test-Prerequisites {
    Write-Header "🔧 Prerequisites Check"
    
    # Check .NET SDK
    try {
        $dotnetVersion = dotnet --version
        Write-ColorOutput "✅ .NET SDK: $dotnetVersion" -Color "Success"
    } catch {
        Write-ColorOutput "❌ .NET SDK not found! Please install .NET 8.0 SDK" -Color "Error"
        exit 1
    }
    
    # Check if we're in the right directory
    if (-not (Test-Path "EdBindings.sln")) {
        Write-ColorOutput "❌ EdBindings.sln not found! Please run this script from the repository root" -Color "Error"
        exit 1
    }
    
    Write-ColorOutput "✅ Prerequisites satisfied" -Color "Success"
}

function Invoke-Restore {
    Write-Header "📦 Package Restore"
    
    try {
        Write-ColorOutput "Restoring NuGet packages..." -Color "Info"
        dotnet restore --verbosity minimal
        Write-ColorOutput "✅ Package restore completed" -Color "Success"
    } catch {
        Write-ColorOutput "❌ Package restore failed: $_" -Color "Error"
        exit 1
    }
}

function Test-CodeFormatting {
    if ($SkipFormatting) {
        Write-ColorOutput "⏭️ Code formatting check skipped" -Color "Warning"
        return
    }
    
    Write-Header "📝 Code Formatting Check"
    
    try {
        Write-ColorOutput "Checking code formatting..." -Color "Info"
        $formatOutput = dotnet format --verify-no-changes --verbosity $($Verbose ? "diagnostic" : "minimal") 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Code formatting is correct" -Color "Success"
        } else {
            Write-ColorOutput "❌ Code formatting issues found:" -Color "Error"
            Write-ColorOutput $formatOutput -Color "Warning"
            Write-ColorOutput "💡 Run 'dotnet format' to fix formatting issues" -Color "Info"
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Code formatting check failed: $_" -Color "Error"
        return $false
    }
    
    return $true
}

function Invoke-Build {
    Write-Header "🏗️ Build"
    
    try {
        Write-ColorOutput "Building solution..." -Color "Info"
        
        $buildArgs = @(
            "build"
            "--configuration", $Configuration
            "--no-restore"
            "--verbosity", ($Verbose ? "normal" : "minimal")
        )
        
        dotnet @buildArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Build successful" -Color "Success"
        } else {
            Write-ColorOutput "❌ Build failed" -Color "Error"
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Build error: $_" -Color "Error"
        return $false
    }
    
    return $true
}

function Invoke-Tests {
    if ($SkipTests) {
        Write-ColorOutput "⏭️ Tests skipped" -Color "Warning"
        return $true
    }
    
    Write-Header "🧪 Unit Tests"
    
    try {
        Write-ColorOutput "Running unit tests..." -Color "Info"
        
        $testArgs = @(
            "test"
            "--configuration", $Configuration
            "--no-build"
            "--verbosity", ($Verbose ? "normal" : "minimal")
            "--collect:XPlat Code Coverage"
            "--results-directory", "./coverage"
            "--logger", "console;verbosity=minimal"
        )
        
        dotnet @testArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ All tests passed" -Color "Success"
            
            # Generate coverage report if reportgenerator is available
            if (Get-Command "reportgenerator" -ErrorAction SilentlyContinue) {
                Write-ColorOutput "Generating coverage report..." -Color "Info"
                
                reportgenerator `
                    -reports:"coverage/**/coverage.cobertura.xml" `
                    -targetdir:"coverage/report" `
                    -reporttypes:"Html;TextSummary" `
                    -title:"EdBindings Local Coverage Report" 2>&1 | Out-Null
                
                if (Test-Path "coverage/report/Summary.txt") {
                    Write-ColorOutput "📊 Coverage Summary:" -Color "Info"
                    Get-Content "coverage/report/Summary.txt" | Select-Object -First 10 | ForEach-Object {
                        Write-ColorOutput "   $_" -Color "Info"
                    }
                    Write-ColorOutput "📁 Full report: coverage/report/index.html" -Color "Info"
                }
            }
        } else {
            Write-ColorOutput "❌ Some tests failed" -Color "Error"
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Test execution error: $_" -Color "Error"
        return $false
    }
    
    return $true
}

function Test-SecurityIssues {
    if ($SkipSecurity) {
        Write-ColorOutput "⏭️ Security checks skipped" -Color "Warning"
        return $true
    }
    
    Write-Header "🛡️ Security Analysis"
    
    # Check for vulnerable packages
    try {
        Write-ColorOutput "Checking for vulnerable dependencies..." -Color "Info"
        
        $vulnerableOutput = dotnet list package --vulnerable --include-transitive 2>&1
        
        if ($vulnerableOutput -match "has the following vulnerable packages") {
            Write-ColorOutput "⚠️ Vulnerable dependencies found:" -Color "Warning"
            Write-ColorOutput $vulnerableOutput -Color "Warning"
            Write-ColorOutput "💡 Consider updating these packages" -Color "Info"
            $hasVulnerabilities = $true
        } else {
            Write-ColorOutput "✅ No vulnerable dependencies found" -Color "Success"
            $hasVulnerabilities = $false
        }
    } catch {
        Write-ColorOutput "❌ Vulnerability check failed: $_" -Color "Error"
        return $false
    }
    
    # Check for hardcoded secrets (basic patterns)
    Write-ColorOutput "Scanning for potential secrets..." -Color "Info"
    
    $secretPatterns = @(
        'password\s*[=:]\s*["\'']\w+["\''']',
        'secret\s*[=:]\s*["\'']\w+["\''']',
        'key\s*[=:]\s*["\'']\w+["\''']',
        'token\s*[=:]\s*["\'']\w+["\''']'
    )
    
    $sourceFiles = Get-ChildItem -Recurse -Include "*.cs", "*.config", "*.json" | 
        Where-Object { $_.Directory.Name -notmatch "bin|obj|\.vs" }
    
    $secretsFound = $false
    foreach ($file in $sourceFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            foreach ($pattern in $secretPatterns) {
                if ($content -match $pattern) {
                    Write-ColorOutput "⚠️ Potential secret in $($file.Name)" -Color "Warning"
                    $secretsFound = $true
                }
            }
        }
    }
    
    if (-not $secretsFound) {
        Write-ColorOutput "✅ No obvious secrets found in code" -Color "Success"
    }
    
    return -not $hasVulnerabilities
}

function Test-CodeQualityMetrics {
    Write-Header "📊 Code Quality Metrics"
    
    try {
        # Count lines of code
        $sourceFiles = Get-ChildItem -Recurse -Include "*.cs" -Exclude "*AssemblyInfo.cs", "*GlobalAssemblyInfo.cs", "*.Designer.cs", "*.g.cs" |
            Where-Object { $_.Directory.Name -notmatch "bin|obj|\.vs" }
        
        $totalLines = 0
        $codeLines = 0
        
        foreach ($file in $sourceFiles) {
            $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
            if ($content) {
                $totalLines += $content.Count
                
                # Count non-empty, non-comment lines
                $nonEmptyLines = $content | Where-Object { 
                    $_.Trim() -ne "" -and 
                    -not $_.Trim().StartsWith("//") -and 
                    -not $_.Trim().StartsWith("/*") -and 
                    -not $_.Trim().StartsWith("*") -and
                    -not $_.Trim().StartsWith("using ")
                }
                $codeLines += $nonEmptyLines.Count
            }
        }
        
        Write-ColorOutput "📁 Source files: $($sourceFiles.Count)" -Color "Info"
        Write-ColorOutput "📏 Total lines: $totalLines" -Color "Info"
        Write-ColorOutput "💻 Code lines: $codeLines" -Color "Info"
        Write-ColorOutput "📊 Code density: $([math]::Round(($codeLines / $totalLines) * 100, 1))%" -Color "Info"
        
        # Check for large files
        $largeFiles = $sourceFiles | Where-Object { (Get-Content $_.FullName -ErrorAction SilentlyContinue).Count -gt 500 }
        if ($largeFiles) {
            Write-ColorOutput "⚠️ Large files (>500 lines):" -Color "Warning"
            foreach ($file in $largeFiles) {
                $lineCount = (Get-Content $file.FullName -ErrorAction SilentlyContinue).Count
                Write-ColorOutput "   $($file.Name): $lineCount lines" -Color "Warning"
            }
        } else {
            Write-ColorOutput "✅ No overly large files detected" -Color "Success"
        }
        
    } catch {
        Write-ColorOutput "❌ Code metrics analysis failed: $_" -Color "Error"
        return $false
    }
    
    return $true
}

function Show-Summary {
    param(
        [bool]$FormatOk,
        [bool]$BuildOk,
        [bool]$TestsOk,
        [bool]$SecurityOk
    )
    
    Write-Header "📋 Quality Check Summary"
    
    $checks = @(
        @{ Name = "Code Formatting"; Status = $FormatOk; Icon = if($FormatOk) {"✅"} else {"❌"} }
        @{ Name = "Build"; Status = $BuildOk; Icon = if($BuildOk) {"✅"} else {"❌"} }
        @{ Name = "Unit Tests"; Status = $TestsOk; Icon = if($TestsOk) {"✅"} else {"❌"} }
        @{ Name = "Security"; Status = $SecurityOk; Icon = if($SecurityOk) {"✅"} else {"❌"} }
    )
    
    foreach ($check in $checks) {
        $color = if ($check.Status) { "Success" } else { "Error" }
        Write-ColorOutput "$($check.Icon) $($check.Name)" -Color $color
    }
    
    $allPassed = $FormatOk -and $BuildOk -and $TestsOk -and $SecurityOk
    
    Write-Host ""
    if ($allPassed) {
        Write-ColorOutput "🎉 All quality checks passed! Your code is ready for PR." -Color "Success"
    } else {
        Write-ColorOutput "❌ Some quality checks failed. Please address the issues above." -Color "Error"
        Write-ColorOutput "💡 Tip: Run individual checks with specific flags to focus on problem areas." -Color "Info"
    }
    
    return $allPassed
}

# Main execution
try {
    $startTime = Get-Date
    
    Write-ColorOutput @"
🚀 EdBindings Local Code Quality Check
=====================================
Configuration: $Configuration
Skip Tests: $SkipTests
Skip Security: $SkipSecurity  
Skip Formatting: $SkipFormatting
Verbose: $Verbose
"@ -Color "Header"
    
    Test-Prerequisites
    Invoke-Restore
    
    $formatOk = Test-CodeFormatting
    $buildOk = Invoke-Build
    $testsOk = if ($buildOk) { Invoke-Tests } else { $false }
    $securityOk = if ($buildOk) { Test-SecurityIssues } else { $false }
    
    Test-CodeQualityMetrics | Out-Null
    
    $allPassed = Show-Summary -FormatOk $formatOk -BuildOk $buildOk -TestsOk $testsOk -SecurityOk $securityOk
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host ""
    Write-ColorOutput "⏱️ Total time: $($duration.TotalSeconds.ToString('F1'))s" -Color "Info"
    
    exit $(if ($allPassed) { 0 } else { 1 })
    
} catch {
    Write-ColorOutput "💥 Unexpected error: $_" -Color "Error"
    Write-ColorOutput $_.ScriptStackTrace -Color "Error"
    exit 1
}