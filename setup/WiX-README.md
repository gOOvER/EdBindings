# WiX Toolset Versions

This project supports multiple WiX versions for maximum compatibility:

## Current: WiX v6.0.2 (Recommended)
- **File**: `setup/EdBindings-v6.wxs`
- **Installation**: `dotnet tool install --global wix --version 6.0.2`
- **Features**: Modern .NET toolset, simplified syntax, better performance
- **License**: Free for MIT-licensed open-source projects like EdBindings

## Fallback: WiX v5.0.2
- **File**: `setup/EdBindings-v5.wxs`
- **Installation**: `dotnet tool install --global wix --version 5.0.2`
- **Features**: .NET-based toolset, stable and mature

## Legacy: WiX v3.14.1
- **File**: `setup/EdBindings.wxs`
- **Installation**: Traditional installer from GitHub releases
- **Features**: Classic toolset, widely compatible

The build script (`Build-MSI.ps1`) automatically detects the installed WiX version and uses the appropriate .wxs file.

## Open Source Maintenance Fee
WiX v6+ requires an [Open Source Maintenance Fee](https://opensourcemaintenancefee.org/) for commercial use, but is free for open-source projects under MIT license like EdBindings.