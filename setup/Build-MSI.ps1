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

# Check for WiX
$wixFound = $false
try {
    $null = Get-Command "candle.exe" -ErrorAction Stop
    $wixFound = $true
    Write-Host "WiX Toolset found" -ForegroundColor Green
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
    $wxsFile = Join-Path $PSScriptRoot "EdBindings.wxs"
    $objFile = Join-Path $OutputPath "EdBindings.wixobj"
    $msiFile = Join-Path $OutputPath "$ProductName-$Version.msi"
    
    Write-Host "Compiling WiX source..." -ForegroundColor Cyan
    Write-Host "Using normalized version: $NormalizedVersion" -ForegroundColor Yellow
    & candle.exe $wxsFile -dSourceDir="$SourcePath" -dVersion="$NormalizedVersion" -o $objFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Linking MSI..." -ForegroundColor Cyan
        & light.exe $objFile -o $msiFile -ext WixUIExtension
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "MSI created: $msiFile" -ForegroundColor Green
            return $true
        }
    }
    
    Write-Host "MSI build failed" -ForegroundColor Red
    return $false
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    return $false
}
