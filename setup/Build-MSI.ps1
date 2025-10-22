param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [string]$Version = "1.0.0",
    [string]$ProductName = "EdBindings"
)

# Normalize version for MSI compatibility (WiX requires x.y.z.w format)
function Normalize-Version {
    param([string]$InputVersion)
    
    # Remove any leading dots or dashes
    $cleanVersion = $InputVersion -replace '^[\.\-]+', ''
    
    # Handle pre-release versions (remove -beta, -alpha, etc.)
    $cleanVersion = $cleanVersion -replace '\-.*$', ''
    
    # Ensure we have at least 3 parts (x.y.z)
    $parts = $cleanVersion.Split('.')
    while ($parts.Length -lt 3) {
        $parts += "0"
    }
    
    # WiX allows max 4 parts, truncate if more
    if ($parts.Length -gt 4) {
        $parts = $parts[0..3]
    }
    
    # Join and validate each part is numeric
    $normalizedParts = @()
    foreach ($part in $parts) {
        $numericPart = [regex]::Match($part, '^\d+').Value
        if ([string]::IsNullOrEmpty($numericPart)) {
            $numericPart = "0"
        }
        $normalizedParts += $numericPart
    }
    
    return $normalizedParts -join '.'
}

$NormalizedVersion = Normalize-Version -InputVersion $Version

Write-Host "Building MSI for $ProductName version $Version (normalized: $NormalizedVersion)" -ForegroundColor Green

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force
}

# Check for WiX (.NET Tool)
$wixFound = $false
$wixVersion = ""
try {
    $wixVersion = & wix --version 2>&1
    if ($wixVersion -match "\d+\.\d+\.\d+") {
        $wixFound = $true
        Write-Host "WiX Toolset found: $wixVersion" -ForegroundColor Green
    } else {
        Write-Host "WiX found but version unclear: $wixVersion" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "WiX Toolset not found, creating instructions" -ForegroundColor Yellow
}

if (-not $wixFound) {
    $guide = @"
EdBindings MSI Build Instructions

1. Install WiX Toolset v3.11+ from https://wixtoolset.org/
2. Run: candle.exe EdBindings.wxs -dSourceDir="$SourcePath" -dVersion="$NormalizedVersion" -o EdBindings.wixobj
3. Run: light.exe EdBindings.wixobj -o "$ProductName-$Version.msi" -ext WixUIExtension

Alternative: Use Visual Studio with Installer Projects extension
"@
    $guide | Out-File -FilePath (Join-Path $OutputPath "BUILD_INSTRUCTIONS.txt") -Encoding UTF8
    return $false
}

try {
    # Use appropriate .wxs file based on WiX version
    $wxsFile = if ($wixFound -and $wixVersion -match "6\.") {
        Join-Path $PSScriptRoot "EdBindings-v6.wxs"
    } elseif ($wixFound -and $wixVersion -match "5\.") {
        Join-Path $PSScriptRoot "EdBindings-v5.wxs"
    } else {
        Join-Path $PSScriptRoot "EdBindings.wxs"
    }
    $objFile = Join-Path $OutputPath "EdBindings.wixobj"
    $msiFile = Join-Path $OutputPath "$ProductName-$Version.msi"
    
    # Validate inputs
    Write-Host "🔍 Validating build environment..." -ForegroundColor Cyan
    Write-Host "WXS File: $wxsFile" -ForegroundColor Gray
    Write-Host "Source Path: $SourcePath" -ForegroundColor Gray
    Write-Host "Output Path: $OutputPath" -ForegroundColor Gray
    
    if (-not (Test-Path $wxsFile)) {
        Write-Host "❌ WiX source file not found: $wxsFile" -ForegroundColor Red
        return $false
    }
    
    if (-not (Test-Path $SourcePath)) {
        Write-Host "❌ Source directory not found: $SourcePath" -ForegroundColor Red
        return $false
    }
    
    # Check for main executable
    $mainExe = Join-Path $SourcePath "EdBindings.exe"
    if (-not (Test-Path $mainExe)) {
        Write-Host "❌ Main executable not found: $mainExe" -ForegroundColor Red
        Write-Host "📁 Available files in source directory:" -ForegroundColor Yellow
        Get-ChildItem $SourcePath -File | ForEach-Object { Write-Host "   $($_.Name)" -ForegroundColor Gray }
        return $false
    }
    
    Write-Host "✅ All required files found" -ForegroundColor Green
    
    Write-Host "Building MSI with WiX..." -ForegroundColor Cyan
    Write-Host "Using normalized version: $NormalizedVersion" -ForegroundColor Yellow
    Write-Host "Command: wix build `"$wxsFile`" -d SourceDir=`"$SourcePath`" -d Version=`"$NormalizedVersion`" -o `"$msiFile`"" -ForegroundColor Gray
    
    $wixResult = & wix build $wxsFile -d "SourceDir=$SourcePath" -d "Version=$NormalizedVersion" -o $msiFile 2>&1
    Write-Host "WiX build output: $wixResult" -ForegroundColor Gray
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MSI created successfully: $msiFile" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ WiX build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "MSI build failed" -ForegroundColor Red
        return $false
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    return $false
}
