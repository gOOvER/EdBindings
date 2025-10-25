# Development Environment & Tools

This document provides a comprehensive overview of all software, tools, and technologies used in the EdBindings project.

## 🔧 Development Environment

### Core Platform
- **Operating System**: Windows 10/11 (primary target platform)
- **Runtime**: .NET 8.0 (LTS)
- **Framework**: WPF (Windows Presentation Foundation)
- **Language**: C# 12 with nullable reference types enabled

### IDE & Editors
- **Primary IDE**: Visual Studio 2022 (Community/Professional/Enterprise)
- **Alternative**: Visual Studio Code with C# extensions
- **Extensions**:
  - C# Dev Kit
  - .NET Install Tool
  - GitLens
  - EditorConfig for VS Code

## 📦 NuGet Packages & Dependencies

### Production Dependencies
```xml
<PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
```

### Development Dependencies
```xml
<PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />
<PackageReference Include="xunit" Version="2.4.2" />
<PackageReference Include="xunit.runner.visualstudio" Version="2.4.5" />
<PackageReference Include="coverlet.collector" Version="6.0.0" />
<PackageReference Include="StyleCop.Analyzers" Version="1.1.118" />
```

## 🚀 Build & Automation Tools

### Microsoft Build Platform
- **MSBuild**: Core build engine
- **NuGet**: Package management
- **dotnet CLI**: Command-line interface

### Code Quality & Analysis
- **StyleCop Analyzers**: Code style enforcement
- **EditorConfig**: Consistent coding standards
- **Roslyn Analyzers**: Static code analysis
- **Code Coverage**: Coverlet for test coverage metrics

### Version Control & Collaboration
- **Git**: Distributed version control
- **GitHub**: Repository hosting and collaboration
- **GitHub Desktop**: GUI Git client (optional)

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows
1. **pr-check.yml**: Pull request validation
2. **security-scan.yml**: Security vulnerability scanning
3. **code-quality.yml**: Code quality and formatting checks
4. **dependency-updates.yml**: Automated dependency management
5. **release.yml**: Automated release and deployment

### Build Agents
- **Runner**: `windows-latest`
- **PowerShell**: 7.x for cross-platform scripts
- **Actions**: Official GitHub Actions and community actions

### Security Tools
- **CodeQL**: Semantic code analysis for security vulnerabilities
- **Dependabot**: Automated security updates
- **SARIF**: Security Analysis Results Interchange Format
- **Typos**: Spell checking for code and documentation

## 🏗️ Installer & Packaging

### WiX Toolset (Windows Installer)
- **Version**: WiX v6.0.2 (latest)
- **Installation**: `dotnet tool install --global wix --version 6.0.2`
- **Features**: Modern .NET-based installer creation
- **License**: Free for MIT-licensed open-source projects

### WiX File Structure
```
setup/
├── EdBindings-v6.wxs      # WiX v6 installer definition (current)
├── EdBindings-v5.wxs      # WiX v5 fallback
├── EdBindings.wxs         # WiX v3 legacy support
├── License.rtf            # MIT license for installer
├── Build-MSI.ps1          # Automated build script
└── WiX-README.md          # WiX version documentation
```

### Distribution Formats
- **MSI**: Professional Windows installer packages
- **ZIP**: Portable self-contained archives
- **GitHub Releases**: Automated release management

## 📊 Testing & Quality Assurance

### Unit Testing Framework
- **xUnit**: Primary testing framework
- **Test Runner**: Visual Studio Test Explorer / `dotnet test`
- **Coverage**: Coverlet for code coverage analysis
- **Mocking**: Built-in .NET testing capabilities

### Code Quality Metrics
- **StyleCop**: Code style and documentation standards
- **Code Coverage**: Target >80% coverage for critical components
- **Static Analysis**: Roslyn analyzers for common issues
- **Security Scanning**: Regular vulnerability assessments

## 🔒 Security & Compliance

### Security Practices
- **Dependency Scanning**: Automated vulnerability detection
- **Code Analysis**: Static security analysis with CodeQL
- **License Compliance**: MIT license compatibility checking
- **Secret Management**: GitHub Secrets for sensitive data

### Compliance Tools
- **SAST**: Static Application Security Testing
- **Dependency Check**: Known vulnerability database scanning
- **License Scanning**: Open source license compliance

## 🌐 External Services & Integrations

### GitHub Services
- **GitHub Actions**: CI/CD automation
- **GitHub Releases**: Distribution platform
- **GitHub Security**: Vulnerability alerts and patches
- **GitHub Pages**: Documentation hosting (future)

### Third-Party Integrations
- **Codecov**: Code coverage reporting and tracking
- **NuGet.org**: Package dependency management
- **Microsoft Learn**: Documentation and learning resources

## 🚀 Deployment & Distribution

### Release Process
1. **Automated Builds**: Every commit triggers CI validation
2. **Quality Gates**: Code quality and security checks
3. **Automated Testing**: Unit tests and integration validation  
4. **Package Creation**: MSI and ZIP archive generation
5. **GitHub Release**: Automated release creation and asset upload

### Release Artifacts
- `EdBindings-{version}-win-x64.zip` - 64-bit portable version
- `EdBindings-{version}-win-x86.zip` - 32-bit portable version  
- `EdBindings-{version}.msi` - Windows installer package
- `MSI_BUILD_GUIDE.md` - Manual build instructions

## 📚 Documentation & Resources

### Project Documentation
- **README.md**: Primary project documentation
- **LICENSE**: MIT license terms
- **CHANGELOG.md**: Version history and changes (future)
- **CONTRIBUTING.md**: Contribution guidelines (future)

### Development Resources
- [.NET 8 Documentation](https://docs.microsoft.com/dotnet/core/whats-new/dotnet-8)
- [WPF Documentation](https://docs.microsoft.com/dotnet/desktop/wpf/)
- [WiX Toolset Documentation](https://wixtoolset.org/docs/)
- [GitHub Actions Documentation](https://docs.github.com/actions)

## 🔮 Future Considerations

### Planned Upgrades
- **Package Management**: Consider using Directory.Packages.props
- **Testing**: Add integration tests and UI automation
- **Documentation**: Implement automated API documentation
- **Localization**: Multi-language support preparation
- **Performance**: Performance monitoring and optimization tools

### Technology Roadmap
- **.NET 9/10**: Future framework upgrades
- **WinUI 3**: Potential UI framework migration
- **MSIX**: Modern Windows packaging evaluation
- **Cloud Integration**: Potential cloud-based features