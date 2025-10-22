# ED:Bindings

A Windows application for Elite Dangerous that reads and displays key binding files in a searchable, filterable format with device mapping support.

[![.NET](https://img.shields.io/badge/.NET-8.0-blue)](https://dotnet.microsoft.com/download/dotnet/8.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![CI](https://github.com/gOOvER/EdBindings/actions/workflows/ci.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/gOOvER/EdBindings/branch/main/graph/badge.svg)](https://codecov.io/gh/gOOvER/EdBindings)
[![Security Scan](https://github.com/gOOvER/EdBindings/actions/workflows/security.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/security.yml)
[![Release](https://github.com/gOOvER/EdBindings/actions/workflows/release.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/release.yml)

<img src="https://raw.githubusercontent.com/ghorsey/EdBindings/main/assets/edbindings.screenshot.gif">

## Features

* Support mapping device codes in Elite to actual labels of device (For example [X56 Bindings](https://www.edrefcard.info/device/SaitekX56))
* Allows filtering bindings by action, key, area, or category
* Includes VoiceAttack/BindED variable names
* Modern .NET 8 WPF application with improved performance and security

## Requirements

* Windows 10 or later
* .NET 8 Runtime

## Installation

### Option 1: Download Release (Recommended)

1. Go to the [Releases page](https://github.com/gOOvER/EdBindings/releases)
2. Download the latest `EdBindings-Setup.msi` installer
3. Run the installer and follow the setup wizard
4. Launch EdBindings from the Start Menu or Desktop shortcut

### Option 2: Portable Version

1. Download the portable ZIP from the [Releases page](https://github.com/gOOvER/EdBindings/releases)
2. Extract to your preferred location
3. Run `EdBindings.exe`

### Option 3: Build from Source

1. Clone the repository: `git clone https://github.com/gOOvER/EdBindings.git`
2. Install [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
3. Build: `dotnet build`
4. Run: `dotnet run --project src/EdBindings`

## Usage

### Getting Started

1. **Launch EdBindings** - Start the application from your Start Menu or Desktop
2. **Load Bindings File** - Click "Load Bindings" or use File → Open to select your Elite Dangerous `.binds` file
   - Default location: `%LOCALAPPDATA%\Frontier Developments\Elite Dangerous\Options\Bindings\`
3. **Select Device Mapping** (Optional) - Choose a device mapping from the dropdown to see friendly names instead of codes
4. **Browse and Search** - Use the search box and filters to find specific key bindings

### Key Features

* **Search**: Type in the search box to filter bindings by action name, key, or device
* **Device Mapping**: Select your HOTAS/controller from the dropdown for human-readable labels
* **Categories**: Filter by binding categories (Flight, Combat, Navigation, etc.)
* **VoiceAttack Integration**: Copy VoiceAttack variable names for voice command integration
* **Export**: Save filtered results or complete binding lists

### Finding Your Bindings File

Elite Dangerous stores binding files in:
```
%LOCALAPPDATA%\Frontier Developments\Elite Dangerous\Options\Bindings\
```

Common binding files:
- `Custom.3.0.binds` - Your custom bindings
- `Keyboard.binds` - Default keyboard layout  
- `GamePad.binds` - Default gamepad layout

## Device Mapping Files

1. The device mapping files are found in the `DeviceMappings` folder
2. The files are in JSON format using the following Schema:

```json
{
  "name": "{{Friendly Device Name, will appear in menu}}", 
  "controls": [
    {
      "deviceId": "{{The device from the ED binds file}}",
      "deviceName": "{{Friendly Device Name to show in the table}}",
      "controlLabel": "{{Friendly name for the key to show in the table}}",
      "controlValue": "{{The key value from the ED binds file}}"
    }
  ]
}
```

See [X56.json](https://github.com/gOOvER/EdBindings/blob/main/src/EdBindings/DeviceMappings/X56.json) for a complete example.

## Building from Source

1. Clone the repository
2. Install .NET 8 SDK
3. Run `dotnet build` in the solution directory
4. Run `dotnet run --project src/EdBindings` to start the application

## Contributing

Please send a PR with additional Device Mapping Files or improvements!

## Credits

* App Icon made by [Nikita Golubev](https://www.flaticon.com/authors/nikita-golubev) from [www.flaticon.com](https://www.flaticon.com/)
