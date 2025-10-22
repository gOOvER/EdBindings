# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the EdBindings project.

## Workflows Overview

### 🤖 CodeRabbit AI Review (`coderabbit.yml`)
**Trigger:** Pull Requests, Review Comments
- **Purpose:** AI-powered code reviews with gaming focus
- **Features:**
  - GPT-4o powered code analysis
  - Elite Dangerous specific pattern recognition
  - Gaming hardware (HOTAS/Joystick) validation
  - WPF gaming performance optimization
  - German language reviews
  - Security analysis for gaming tools
  - MSI installer security validation

### � Pull Request Checks (`pr-check.yml`)
**Trigger:** Pull Requests to main/develop branches
- **Purpose:** Comprehensive PR validation pipeline
- **Features:**
  - Integrates CodeRabbit AI review as first step
  - Build validation on Windows runners
  - Unit test execution
  - Code formatting validation
  - Security scanning coordination
  - Gaming-specific compatibility checks

### �🔄 CI Workflow (`ci.yml`)
**Trigger:** Push to main/develop branches, Pull Requests to main
- **Purpose:** Continuous Integration testing
- **Features:**
  - Builds project in Debug and Release configurations
  - Runs all unit tests with code coverage
  - Validates code formatting
  - Uploads coverage reports to Codecov (optional)
  - Caches NuGet packages for faster builds

### 🚀 Release Workflow (`release.yml`)
**Trigger:** Git tags (v*.*.*) or manual dispatch
- **Purpose:** Create releases with built artifacts
- **Features:**
  - Builds self-contained executables for Windows x64/x86
  - Creates MSI installers with WiX Toolset v6
  - Creates ZIP archives for distribution
  - Generates detailed release notes
  - Creates GitHub releases with artifacts
  - Supports both tagged releases and manual triggers

### 📦 Dependency Updates (`dependency-updates.yml`)
**Trigger:** Weekly schedule or manual dispatch
- **Purpose:** Automated dependency management
- **Features:**
  - Monitors for NuGet package updates
  - Creates automated PRs for updates
  - Ensures dependencies stay current and secure
  - Gaming-library compatibility checking

## Setup Instructions

### 1. Repository Secrets (Required for CodeRabbit)
Add these secrets in your GitHub repository settings:

- `OPENAI_API_KEY`: Required for CodeRabbit AI reviews (get from OpenAI)
- `CODECOV_TOKEN`: For code coverage reporting with Codecov.io (optional but recommended)

### 2. Branch Protection (Recommended)
Configure branch protection rules for `main` branch:
- Require status checks to pass before merging
- Require CodeRabbit review to pass
- Require CI workflow to pass  
- Require up-to-date branches before merging

### 3. CodeRabbit Configuration
CodeRabbit is automatically configured with:
- Gaming-specific rules for Elite Dangerous integration
- German language reviews
- WPF performance optimization checks
- HOTAS/Gaming hardware validation
- MSI installer security analysis

### 4. Release Process
To create a release:

#### Automatic (Recommended):
1. Create and push a git tag: `git tag v1.0.0 && git push origin v1.0.0`
2. The release workflow will automatically build MSI and ZIP artifacts

#### Manual:
1. Go to Actions tab in GitHub
2. Select "Release" workflow
3. Click "Run workflow"
4. Enter the version (e.g., v1.0.0)
5. Click "Run workflow"

## Workflow Status Badges

Current badges in main README.md:

```markdown
[![CI](https://github.com/gOOvER/EdBindings/actions/workflows/ci.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/ci.yml)
[![CodeRabbit](https://img.shields.io/badge/Code%20Review-AI%20Powered-brightgreen)](https://github.com/gOOvER/EdBindings/actions/workflows/coderabbit.yml)
[![Release](https://github.com/gOOvER/EdBindings/actions/workflows/release.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/release.yml)
```

## 🤖 CodeRabbit Integration Benefits

### Replaced Workflows
The following workflows were consolidated into CodeRabbit:
- ❌ `code-quality.yml` → Now handled by CodeRabbit AI
- ❌ `security-scan.yml` → Security analysis in CodeRabbit
- ❌ `security.yml` → Integrated into CodeRabbit reviews  
- ❌ `dependency-check.yml` → Dependency analysis in CodeRabbit

### Enhanced Features with CodeRabbit
- 🎮 **Gaming-Specific Analysis**: Elite Dangerous integration patterns
- 🕹️ **Hardware Validation**: HOTAS/Joystick device support checks
- 🛡️ **Security-First**: Gaming tool security best practices
- 🇩🇪 **Localized Reviews**: German language feedback
- ⚡ **Performance Focus**: Gaming UI responsiveness optimization

## Troubleshooting

### Common Issues:

1. **CodeRabbit Reviews Missing**: Ensure `OPENAI_API_KEY` is set in repository secrets

2. **MSI Build Fails**: WiX Toolset v6 is used - check setup/Build-MSI.ps1 for details

3. **Tests Fail**: All tests must pass locally before pushing. CI treats warnings as errors.

4. **Code Formatting Fails**: Use dotnet format before committing:
   - Run `dotnet format` to auto-format code
   - Commit formatted changes and push again

### Local Testing:
Before pushing, test locally:

```powershell
# Test formatting and build
dotnet format --verify-no-changes
dotnet restore  
dotnet build --configuration Release
dotnet test --configuration Release

# Test MSI creation (Windows only)
.\setup\Build-MSI.ps1 -Version "1.0.0-test" -SourcePath ".\src\EdBindings\bin\Release\net8.0-windows\"
```

### CodeRabbit Configuration:
- Main config: `.coderabbit.yaml`
- Gaming rules: `.coderabbit/config.yaml`  
- Custom prompts: `.coderabbit/prompts.md`
- Feedback template: `.github/ISSUE_TEMPLATE/coderabbit-feedback.md`

## Customization

You can customize these workflows by:
- Modifying trigger conditions
- Adding additional build configurations
- Changing artifact retention periods
- Adding notification integrations (Slack, Teams, etc.)
- Adding additional security scanners

For more information about GitHub Actions, see the [GitHub Actions documentation](https://docs.github.com/en/actions).
