# ED:Bindings

A Windows application for Elite Dangerous that reads and displays key binding files in a searchable, filterable format with device mapping support.

[![.NET](https://img.shields.io/badge/.NET-8.0-blue)](https://dotnet.microsoft.com/download/dotnet/8.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![CI](https://github.com/gOOvER/EdBindings/actions/workflows/ci.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/ci.yml)
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
