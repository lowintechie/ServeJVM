<#
.SYNOPSIS
    Installation script for ServeJVM.

.DESCRIPTION
    This script clones the ServeJVM repository, copies the jvm.ps1 file to .serveJVM/bin,
    updates the PATH environment variable, and cleans up by removing the ServeJVM folder.

.NOTES
    Author: LOWIN TECHIE
    Version: 1.1
    Date: 2024-08-16
#>

# Define variables
$repoUrl = "https://github.com/lowinn/ServeJVM.git"
$installDir = "$env:USERPROFILE\.serveJVM"
$serveJvmDir = "$installDir\ServeJVM"
$binDir = "$installDir\bin"
$scriptFile = "$binDir\jvm.ps1"
$logFile = "$installDir\install.log"

# Ensure the installation and bin directories exist
try {
    if (-not (Test-Path -Path $binDir)) {
        New-Item -ItemType Directory -Path $binDir -Force | Out-Null
        Start-Sleep -Milliseconds 500  # Wait to ensure the directory is fully created
        if (-not (Test-Path -Path $binDir)) {
            throw "Directory $binDir could not be created."
        }
        Write-Output "Created bin directory at $binDir."
    }
} catch {
    Write-Output "ERROR: Failed to create bin directory at $binDir. $_"
    exit 1
}

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Output $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Function to handle errors
function Error-Exit {
    param (
        [string]$message
    )
    Log-Message "ERROR: $message"
    Log-Message "Installation failed. Please check the log file at $logFile for more details."
    exit 1
}

# Start the installation process
Log-Message "Starting ServeJVM installation..."

# Check if Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Error-Exit "Git is not installed or not found in PATH. Please install Git and try again."
}

# Clone the repository
try {
    git clone $repoUrl $serveJvmDir 2>>$logFile  # Clone directly into the ServeJVM subdirectory
} catch {
    Error-Exit "Failed to clone the repository from $repoUrl."
}

# Copy jvm.ps1 to .serveJVM/bin
try {
    $sourceFile = "$serveJvmDir\bin\jvm.ps1"
    if (Test-Path -Path $sourceFile) {
        Copy-Item -Path $sourceFile -Destination $scriptFile -Force
    } else {
        Error-Exit "The 'jvm.ps1' file does not exist in the cloned repository."
    }
} catch {
    Error-Exit "Failed to copy jvm.ps1 to $scriptFile."
}

# Remove the ServeJVM folder
try {
    Remove-Item -Recurse -Force $serveJvmDir
} catch {
    Log-Message "Failed to remove the ServeJVM folder. $_"
}

# Update PATH in the user environment
try {
    if ($env:Path -notmatch [regex]::Escape("$binDir")) {
        [Environment]::SetEnvironmentVariable("Path", "$binDir;$env:Path", [System.EnvironmentVariableTarget]::User)
        Log-Message "Updated PATH in user environment."
    } else {
        Log-Message "PATH already contains $binDir."
    }
} catch {
    Error-Exit "Failed to update the PATH environment variable."
}

# Final message to the user
Log-Message "ServeJVM installed successfully. Restart your terminal or open a new one to start using it."
