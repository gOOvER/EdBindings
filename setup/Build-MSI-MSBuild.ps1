param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $true)]
    [string]$SourcePath
)

Write-Host "🔨 Building MSI with WiX Toolset..." -ForegroundColor Yellow
Write-Host "Version: $Version" -ForegroundColor Cyan
Write-Host "Source Path: $SourcePath" -ForegroundColor Cyan

# Ensure output directory exists
$publishDir = ".\publish"
if (-not (Test-Path $publishDir)) {
    New-Item -ItemType Directory -Path $publishDir -Force | Out-Null
}

# Check if source directory exists and has files
if (-not (Test-Path $SourcePath)) {
    Write-Error "❌ Source path does not exist: $SourcePath"
    exit 1
}

$sourceFiles = Get-ChildItem -Path $SourcePath -File
if ($sourceFiles.Count -eq 0) {
    Write-Error "❌ No files found in source path: $SourcePath"
    exit 1
}

Write-Host "📁 Found $($sourceFiles.Count) files in source directory" -ForegroundColor Green

# Build using MSBuild project
Write-Host "🔧 Building MSI using WiX MSBuild project..." -ForegroundColor Yellow

try {
    # Set location to setup directory
    Push-Location ".\setup"
    
    # Build the WiX project
    $buildResult = dotnet build EdBindings.wixproj -p:Version=$Version -p:SourceDir=$SourcePath -c Release -v minimal
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MSI created successfully" -ForegroundColor Green
        
        # Check if MSI was created
        $msiPath = "..\publish\EdBindings-$Version.msi"
        if (Test-Path $msiPath) {
            $msiInfo = Get-Item $msiPath
            Write-Host "📦 MSI Size: $([math]::Round($msiInfo.Length/1024,1)) KB" -ForegroundColor Cyan
            Write-Host "📍 MSI Location: $(Resolve-Path $msiPath)" -ForegroundColor Cyan
        } else {
            Write-Warning "⚠️ MSI file not found at expected location: $msiPath"
        }
    } else {
        Write-Error "❌ MSI build failed"
        exit 1
    }
} catch {
    Write-Error "❌ Error during build: $($_.Exception.Message)"
    exit 1
} finally {
    Pop-Location
}

Write-Host "🎉 Build completed!" -ForegroundColor Green