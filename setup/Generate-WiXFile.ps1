param(
    [string]$SourceDir = ".\publish\win-x64\"
)

Write-Host "🔍 Generating complete WiX configuration..." -ForegroundColor Green
Write-Host "🔍 Scanning source directory: $SourceDir" -ForegroundColor Cyan

# Stelle sicher, dass der Pfad existiert
if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
    exit 1
}

# Sammle alle Dateien
$sourceItem = Get-Item $SourceDir
$allFiles = Get-ChildItem -Path $SourceDir -Recurse -File

Write-Host "📋 Found $($allFiles.Count) files to include" -ForegroundColor Yellow

# Erzeuge WiX Content
$wxsContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://wixtoolset.org/schemas/v4/wxs">
  <Package Id="EdBindingsPackage"
           Name="Elite Dangerous Bindings Viewer"
           Language="1033"
           Version="`$(var.Version)"
           Manufacturer="Elite Dangerous Tools"
           UpgradeCode="12345678-1234-1234-1234-123456789012">

    <MajorUpgrade DowngradeErrorMessage="A newer version is already installed." />
    <MediaTemplate EmbedCab="yes" />

    <!-- Icon Definition -->
    <Icon Id="EdBindings.exe" SourceFile="`$(var.SourceDir)/EdBindings.exe" />

    <!-- Properties for customization -->
    <Property Id="ARPPRODUCTICON" Value="EdBindings.exe" />
    <Property Id="ARPHELPLINK" Value="https://github.com/gOOvER/EdBindings" />
    <Property Id="ARPURLINFOABOUT" Value="https://github.com/gOOvER/EdBindings" />
    <Property Id="ARPCOMMENTS" Value="Elite Dangerous Bindings Viewer - View and manage your Elite Dangerous key bindings" />

    <!-- Standard directory structure -->
    <StandardDirectory Id="ProgramFilesFolder">
      <Directory Id="INSTALLFOLDER" Name="EdBindings">
        <Directory Id="DeviceMappingsFolder" Name="DeviceMappings" />
      </Directory>
    </StandardDirectory>

    <!-- Features -->
    <Feature Id="ProductFeature" Title="Elite Dangerous Bindings Viewer" Level="1">
      <ComponentRef Id="MainExecutable" />
      <ComponentRef Id="AllApplicationFiles" />
      <ComponentRef Id="DeviceMappingsFiles" />
    </Feature>

    <!-- Components -->
    <DirectoryRef Id="INSTALLFOLDER">
      <!-- Main executable -->
      <Component Id="MainExecutable" Guid="12345678-9ABC-DEF0-1234-56789ABCDEF0">
        <File Id="MainExe"
              Source="`$(var.SourceDir)/EdBindings.exe"
              KeyPath="yes">
          <Shortcut Id="DesktopShortcut"
                    Directory="DesktopFolder"
                    Name="Elite Dangerous Bindings Viewer"
                    WorkingDirectory="INSTALLFOLDER"
                    Icon="EdBindings.exe"
                    IconIndex="0" />
          <Shortcut Id="StartMenuShortcut"
                    Directory="ProgramMenuFolder"
                    Name="Elite Dangerous Bindings Viewer"
                    WorkingDirectory="INSTALLFOLDER"
                    Icon="EdBindings.exe"
                    IconIndex="0" />
        </File>
      </Component>

      <!-- All other files -->
      <Component Id="AllApplicationFiles" Guid="11111111-2222-3333-4444-555555555555">
"@

# Erzeuge File-Element für jede Datei (außer der Hauptanwendung)
$componentId = 1
foreach ($file in $allFiles) {
    if ($file.Name -eq "EdBindings.exe") {
        # Hauptanwendung wird separat behandelt
        continue
    }
    if ($file.Name -eq "X56.json" -and $file.DirectoryName -match "DeviceMappings") {
        # X56.json wird separat behandelt
        continue
    }

    # Erstelle relativen Pfad von der Basis des Source-Verzeichnisses
    $relativePath = $file.FullName.Substring($sourceItem.FullName.Length)
    if ($relativePath.StartsWith('\')) {
        $relativePath = $relativePath.Substring(1)
    }
    # Konvertiere Windows-Pfade zu WiX-kompatiblen Pfaden (Forward Slashes)
    $relativePath = $relativePath -replace '\\', '/'
    $fileName = $file.Name
    $safeId = "File_" + ($fileName -replace '[^A-Za-z0-9_.]', '_') + "_$componentId"

    # Stelle sicher, dass IDs nicht zu lang werden
    if ($safeId.Length -gt 50) {
        $safeId = "File_$componentId"
    }

    $wxsContent += @"
        <File Id="$safeId"
              Source="`$(var.SourceDir)/$relativePath" />
"@

    $componentId++
}

$wxsContent += @"
      </Component>
    </DirectoryRef>

    <!-- Device Mappings Component -->
    <DirectoryRef Id="DeviceMappingsFolder">
      <Component Id="DeviceMappingsFiles" Guid="22222222-3333-4444-5555-666666666666">
        <File Id="X56JsonFile"
              Source="`$(var.SourceDir)/DeviceMappings/X56.json"
              KeyPath="yes" />
      </Component>
    </DirectoryRef>

    <!-- Desktop Folder -->
    <StandardDirectory Id="DesktopFolder" />
    <StandardDirectory Id="ProgramMenuFolder" />
  </Package>
</Wix>
"@

# Schreibe WiX-Datei
$outputPath = Join-Path (Split-Path $PSCommandPath) "EdBindings-Generated.wxs"
$wxsContent | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "✅ Generated WiX file: $outputPath" -ForegroundColor Green
Write-Host "📄 Included $($allFiles.Count) files in the installer" -ForegroundColor Cyan

return $outputPath
