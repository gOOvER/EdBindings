# EdBindings MSI Build Script
# Creates an MSI installer using WiX Toolset or alternative tools

param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [string]$Version = "1.0.0",
    [string]$ProductName = "EdBindings",
    [string]$Manufacturer = "Elite Dangerous Community"
)

Write-Host "🔨 Building MSI installer for $ProductName v$Version" -ForegroundColor Green

# Check if WiX is available
$wixPath = Get-Command "candle.exe" -ErrorAction SilentlyContinue
if (-not $wixPath) {
    Write-Host "❌ WiX Toolset not found. Attempting alternative MSI creation..." -ForegroundColor Yellow
    
    # Alternative: Use Advanced Installer CLI or other tools
    # For now, create a detailed batch file for manual MSI creation
    $batchContent = @"
@echo off
echo EdBindings MSI Build Instructions
echo ================================
echo.
echo Source Path: $SourcePath
echo Output Path: $OutputPath
echo Version: $Version
echo.
echo Manual Steps:
echo 1. Install WiX Toolset v3.11 or later
echo 2. Run: candle.exe EdBindings.wxs -o EdBindings.wixobj
echo 3. Run: light.exe EdBindings.wixobj -o "$ProductName-$Version.msi"
echo.
echo Alternative Tools:
echo - Advanced Installer (https://www.advancedinstaller.com/)
echo - NSIS (Nullsoft Scriptable Install System)
echo - Inno Setup (Free installer)
echo.
pause
"@

    $batchPath = Join-Path $OutputPath "BuildMSI.bat"
    Set-Content -Path $batchPath -Value $batchContent
    
    Write-Host "📝 Created manual build script: $batchPath" -ForegroundColor Yellow
    Write-Host "ℹ️  Please install WiX Toolset or use Visual Studio for MSI creation" -ForegroundColor Cyan
    
    # Create a comprehensive README for MSI building
    $readmeContent = @"
# EdBindings MSI Build Guide

## Automated MSI Building (Recommended)

### Prerequisites
- Install [WiX Toolset v3.11+](https://wixtoolset.org/releases/)
- OR Install Visual Studio 2022 with "Microsoft Visual Studio Installer Projects" extension

### Option 1: WiX Toolset (CLI)
``````bash
# Navigate to setup directory
cd setup

# Compile WiX source
candle.exe EdBindings.wxs -dSourceDir="../src/EdBindings/bin/Release/net8.0-windows/publish/"

# Create MSI
light.exe EdBindings.wixobj -o "EdBindings-$Version.msi" -ext WixUIExtension
``````

### Option 2: Visual Studio (GUI)
1. Open `setup/EDBindingsSetup/EDBindingsSetup.vdproj` in Visual Studio
2. Set build configuration to "Release"
3. Build the solution (Ctrl+Shift+B)
4. MSI will be created in `setup/EDBindingsSetup/Release/`

### Option 3: Advanced Installer
1. Create new project in Advanced Installer
2. Add files from publish directory
3. Configure product details and shortcuts
4. Build MSI package

## Alternative Installer Solutions

### NSIS (Nullsoft Scriptable Install System)
- Lightweight and flexible
- Script-based configuration
- Good for simple installations

### Inno Setup
- Free Pascal-based installer
- Professional-looking installers
- Good documentation and community

### Squirrel.Windows
- Modern .NET installer framework
- Supports automatic updates
- NuGet package distribution

## GitHub Actions Integration

For automated builds in CI/CD, consider:
- Using WiX with GitHub Actions
- Creating portable ZIP releases instead of MSI
- Using Chocolatey for package distribution

## Current Status
- Manual MSI creation required
- WiX source files provided for future automation
- ZIP releases available for immediate distribution
"@

    $readmePath = Join-Path $OutputPath "MSI_BUILD_GUIDE.md"
    Set-Content -Path $readmePath -Value $readmeContent
    
    Write-Host "📖 Created comprehensive build guide: $readmePath" -ForegroundColor Green
    
    return $false
}

Write-Host "✅ WiX Toolset found at: $($wixPath.Source)" -ForegroundColor Green

# Create MSI using WiX
try {
    $wxsPath = Join-Path (Split-Path $PSScriptRoot) "EdBindings.wxs"
    $wixObjPath = Join-Path $OutputPath "EdBindings.wixobj"
    $msiPath = Join-Path $OutputPath "$ProductName-$Version.msi"
    
    Write-Host "🔥 Compiling WiX source..." -ForegroundColor Cyan
    & candle.exe $wxsPath -dSourceDir="$SourcePath" -o $wixObjPath
    
    if ($LASTEXITCODE -ne 0) {
        throw "WiX compilation failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "💡 Linking MSI package..." -ForegroundColor Cyan  
    & light.exe $wixObjPath -o $msiPath -ext WixUIExtension
    
    if ($LASTEXITCODE -ne 0) {
        throw "WiX linking failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "🎉 MSI created successfully: $msiPath" -ForegroundColor Green
    return $true
}
catch {
    Write-Host "❌ MSI creation failed: $_" -ForegroundColor Red
    Write-Host "💡 Falling back to manual build instructions..." -ForegroundColor Yellow
    return $false
}