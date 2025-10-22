# WiX Setup Guide for EdBindings

This directory contains the WiX v6 configuration for creating MSI installers for the EdBindings application.

## Files

- `EdBindings.wxs` - WiX v6 installer configuration
- `Build-MSI.ps1` - PowerShell build script
- `License.rtf` - License text for the installer

## Prerequisites

Install WiX Toolset v6.0.2:
```powershell
dotnet tool install --global wix --version 6.0.2
```

## Building the MSI

Use the PowerShell build script:

```powershell
.\setup\Build-MSI.ps1 -SourcePath ".\src\EdBindings\bin\Release\net8.0-windows\" -OutputPath ".\publish\" -Version "1.0.14"
```

### Parameters

- `SourcePath` - Path to the compiled application files
- `OutputPath` - Where to save the generated MSI
- `Version` - Version number for the installer

## Features

The installer includes:
- Main application (`EdBindings.exe`)
- Required libraries (`EdBindings.Model.dll`, `Newtonsoft.Json.dll`)
- Runtime configuration files
- Device mappings (`X56.json`)
- Start menu and desktop shortcuts
- Proper uninstall support

## License

WiX v6 is free for open-source projects under MIT license like EdBindings.