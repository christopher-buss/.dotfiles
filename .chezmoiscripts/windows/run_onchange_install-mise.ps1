#!/usr/bin/env pwsh

# Install and configure mise development environment
# This script runs whenever the mise configuration changes

$ErrorActionPreference = "Stop"

Write-Host "Setting up mise development environment..." -ForegroundColor Cyan

# Helper function for logging
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "INFO" { "White" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Check if mise is installed
function Test-MiseInstalled {
    try {
        $null = Get-Command mise -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Install mise if not present
function Install-Mise {
    if (Test-MiseInstalled) {
        Write-Log "mise is already installed" "SUCCESS"
        return
    }
    
    Write-Log "Installing mise via winget..." "INFO"
    try {
        winget install --id jdx.mise --source winget --accept-package-agreements --accept-source-agreements
        Write-Log "mise installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Failed to install mise: $_" "ERROR"
        throw
    }
}

# Setup mise configuration
function Setup-MiseConfig {
    Write-Log "Setting up mise configuration..." "INFO"
    
    # Create mise config directory
    $configDir = "$env:USERPROFILE\.config\mise"
    if (!(Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        Write-Log "Created mise config directory: $configDir" "INFO"
    }
    
    # Copy mise configuration from chezmoidata
    $sourceConfig = "{{ .chezmoi.sourceDir }}/.chezmoidata/mise/config.toml"
    $targetConfig = "$configDir\config.toml"
    
    if (Test-Path $sourceConfig) {
        Copy-Item $sourceConfig $targetConfig -Force
        Write-Log "Copied mise configuration to $targetConfig" "SUCCESS"
    }
    else {
        Write-Log "mise config.toml not found at $sourceConfig" "WARNING"
    }
}

# Setup global tool versions
function Setup-GlobalToolVersions {
    Write-Log "Setting up global tool versions..." "INFO"
    
    $sourceToolVersions = "{{ .chezmoi.sourceDir }}/.chezmoidata/tool-versions"
    $targetToolVersions = "$env:USERPROFILE\.tool-versions"
    
    if (Test-Path $sourceToolVersions) {
        Copy-Item $sourceToolVersions $targetToolVersions -Force
        Write-Log "Copied global .tool-versions to $targetToolVersions" "SUCCESS"
    }
    else {
        Write-Log "Global .tool-versions not found at $sourceToolVersions" "WARNING"
    }
}

# Install development tools
function Install-DevelopmentTools {
    Write-Log "Installing development tools from .tool-versions..." "INFO"
    
    $toolVersionsPath = "$env:USERPROFILE\.tool-versions"
    if (!(Test-Path $toolVersionsPath)) {
        Write-Log ".tool-versions file not found at $toolVersionsPath" "ERROR"
        return
    }
    
    try {
        # Change to user profile directory to use global .tool-versions
        Push-Location $env:USERPROFILE
        
        # Install all tools from .tool-versions
        mise install
        Write-Log "Development tools installed successfully" "SUCCESS"
        
        # Show installed tools
        Write-Log "Installed tools:" "INFO"
        mise list
    }
    catch {
        Write-Log "Failed to install development tools: $_" "ERROR"
        throw
    }
    finally {
        Pop-Location
    }
}

# Install global packages
function Install-GlobalPackages {
    Write-Log "Installing global packages..." "INFO"
    
    $globalPackagesDir = "{{ .chezmoi.sourceDir }}/.chezmoidata/global-packages"
    
    # Install npm global packages
    $npmGlobalFile = "$globalPackagesDir\npm-global.txt"
    if (Test-Path $npmGlobalFile) {
        Write-Log "Installing global npm packages..." "INFO"
        try {
            $packages = Get-Content $npmGlobalFile | Where-Object { $_ -notmatch '^#' -and $_ -notmatch '^$' }
            if ($packages.Count -gt 0) {
                $packagesString = $packages -join ' '
                mise exec -- npm install -g $packagesString
                Write-Log "Global npm packages installed successfully" "SUCCESS"
            }
        }
        catch {
            Write-Log "Failed to install npm packages: $_" "WARNING"
        }
    }
    
    # Install pip global packages
    $pipGlobalFile = "$globalPackagesDir\pip-global.txt"
    if (Test-Path $pipGlobalFile) {
        Write-Log "Installing global pip packages..." "INFO"
        try {
            mise exec -- pip install -r $pipGlobalFile
            Write-Log "Global pip packages installed successfully" "SUCCESS"
        }
        catch {
            Write-Log "Failed to install pip packages: $_" "WARNING"
        }
    }
    
    # Install cargo tools
    $cargoToolsFile = "$globalPackagesDir\cargo-tools.txt"
    if (Test-Path $cargoToolsFile) {
        Write-Log "Installing Rust cargo tools..." "INFO"
        try {
            $tools = Get-Content $cargoToolsFile | Where-Object { $_ -notmatch '^#' -and $_ -notmatch '^$' }
            foreach ($tool in $tools) {
                mise exec -- cargo install $tool
            }
            Write-Log "Cargo tools installed successfully" "SUCCESS"
        }
        catch {
            Write-Log "Failed to install cargo tools: $_" "WARNING"
        }
    }
}

# Setup PowerShell profile integration
function Setup-PowerShellIntegration {
    Write-Log "Setting up PowerShell integration..." "INFO"
    
    $profilePath = $PROFILE
    $profileDir = Split-Path $profilePath -Parent
    
    # Create profile directory if it doesn't exist
    if (!(Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    # Check if mise activation is already in profile
    if (Test-Path $profilePath) {
        $profileContent = Get-Content $profilePath -Raw
        if ($profileContent -match "mise activate") {
            Write-Log "mise activation already present in PowerShell profile" "INFO"
            return
        }
    }
    
    # Add mise activation to profile
    $miseActivation = @"

# mise activation
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Invoke-Expression (& mise activate pwsh)
}
"@
    
    Add-Content -Path $profilePath -Value $miseActivation
    Write-Log "Added mise activation to PowerShell profile: $profilePath" "SUCCESS"
}

# Run comprehensive mise validation
function Test-MiseInstallation {
    Write-Log "Running comprehensive mise validation..." "INFO"
    
    # Test basic installation
    try {
        Write-Log "Checking mise installation..." "INFO"
        mise --version
        Write-Log "mise is properly installed" "SUCCESS"
    }
    catch {
        Write-Log "mise is not properly installed: $_" "ERROR"
        return $false
    }
    
    # Validate configuration
    try {
        Write-Log "Validating mise configuration..." "INFO"
        mise config
        Write-Log "mise configuration is valid" "SUCCESS"
    }
    catch {
        Write-Log "mise configuration has issues: $_" "WARNING"
    }
    
    # Check installed tools
    try {
        Write-Log "Checking installed tools..." "INFO"
        mise list --installed
        Write-Log "Tools list retrieved successfully" "SUCCESS"
    }
    catch {
        Write-Log "Could not retrieve tools list: $_" "WARNING"
    }
    
    # Run doctor for comprehensive check
    try {
        Write-Log "Running mise doctor..." "INFO"
        mise doctor
        Write-Log "mise doctor completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "mise doctor reported issues: $_" "WARNING"
    }
    
    # Verify environment setup
    try {
        Write-Log "Checking environment setup..." "INFO"
        mise env | Out-String | Write-Host
        Write-Log "Environment variables configured correctly" "SUCCESS"
    }
    catch {
        Write-Log "Environment setup has issues: $_" "WARNING"
    }
    
    return $true
}

# Main execution
try {
    Write-Log "Starting mise setup process..." "INFO"
    
    Install-Mise
    Setup-MiseConfig
    Setup-GlobalToolVersions
    Install-DevelopmentTools
    Install-GlobalPackages
    Setup-PowerShellIntegration
    Test-MiseInstallation
    
    Write-Log "✅ mise setup completed successfully!" "SUCCESS"
    Write-Log "Restart your shell or run 'mise activate powershell | Invoke-Expression' to start using mise" "INFO"
}
catch {
    Write-Log "❌ mise setup failed: $_" "ERROR"
    exit 1
}