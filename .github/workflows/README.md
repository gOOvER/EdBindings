# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the EdBindings project.

## Workflows Overview

### 🔄 CI Workflow (`ci.yml`)
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
  - Creates ZIP archives for distribution
  - Generates detailed release notes
  - Creates GitHub releases with artifacts
  - Supports both tagged releases and manual triggers

### 📦 Dependency Check (`dependency-check.yml`)
**Trigger:** Weekly schedule (Mondays) or manual dispatch
- **Purpose:** Monitor for outdated NuGet packages
- **Features:**
  - Uses dotnet-outdated tool to scan packages
  - Generates reports on package versions
  - Helps maintain up-to-date dependencies

### 🔒 Security Scan (`security.yml`)
**Trigger:** Push/PR to main, weekly schedule (Sundays)
- **Purpose:** Security vulnerability scanning
- **Features:**
  - Scans for vulnerable NuGet packages
  - Runs CodeQL security analysis
  - Generates security audit reports
  - Helps identify potential security issues

## Setup Instructions

### 1. Repository Secrets (Optional)
Add these secrets in your GitHub repository settings if you want enhanced features:

- `CODECOV_TOKEN`: For code coverage reporting (optional)

### 2. Branch Protection (Recommended)
Configure branch protection rules for `main` branch:
- Require status checks to pass before merging
- Require CI workflow to pass
- Require up-to-date branches before merging

### 3. Release Process
To create a release:

#### Automatic (Recommended):
1. Create and push a git tag: `git tag v1.0.0 && git push origin v1.0.0`
2. The release workflow will automatically build and create the release

#### Manual:
1. Go to Actions tab in GitHub
2. Select "Release" workflow
3. Click "Run workflow"
4. Enter the version (e.g., v1.0.0)
5. Click "Run workflow"

## Workflow Status Badges

Add these badges to your main README.md:

```markdown
[![CI](https://github.com/gOOvER/EdBindings/actions/workflows/ci.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/ci.yml)
[![Security Scan](https://github.com/gOOvER/EdBindings/actions/workflows/security.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/security.yml)
[![Release](https://github.com/gOOvER/EdBindings/actions/workflows/release.yml/badge.svg)](https://github.com/gOOvER/EdBindings/actions/workflows/release.yml)
```

## Troubleshooting

### Common Issues:

1. **MSI Build Fails**: The setup project requires Visual Studio with VDPROJ extension. The workflow creates a note file instead of building the MSI automatically.

2. **Tests Fail**: Check that all tests pass locally before pushing. The CI workflow treats warnings as errors.

3. **Release Artifacts Missing**: Ensure the project builds successfully and all paths in the workflow are correct.

### Local Testing:
Before pushing, you can test the build process locally:

```bash
# Test CI build
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release

# Test release build
dotnet publish src/EdBindings/EdBindings.csproj --configuration Release --runtime win-x64 --self-contained true
```

## Customization

You can customize these workflows by:
- Modifying trigger conditions
- Adding additional build configurations
- Changing artifact retention periods
- Adding notification integrations (Slack, Teams, etc.)
- Adding additional security scanners

For more information about GitHub Actions, see the [GitHub Actions documentation](https://docs.github.com/en/actions).
