param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [string]$Version = "1.0.0",
    [string]$ProductName = "EdBindings"
)

Write-Host "Building MSI for $ProductName version $Version" -ForegroundColor Green

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
2. Run: candle.exe EdBindings.wxs -dSourceDir="$SourcePath" -dVersion="$Version" -o EdBindings.wixobj
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
    & candle.exe $wxsFile -dSourceDir="$SourcePath" -dVersion="$Version" -o $objFile
    
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
