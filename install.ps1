<#
.SYNOPSIS
    Installation script for ServeJVM.

.DESCRIPTION
    This script clones the ServeJVM repository, updates the PATH environment variable, and sets up ServeJVM for use.

.NOTES
    Author: LOWIN TECHIE
    Version: 1.0
    Date: 2024-08-16
#>

# Define variables
$repoUrl = "https://github.com/lowinn/ServeJVM.git"
$installDir = "$env:USERPROFILE\.serveJVM"
$logFile = "$installDir\install.log"

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
    git clone $repoUrl $installDir 2>>$logFile
    Log-Message "Repository cloned successfully to $installDir."
} catch {
    Error-Exit "Failed to clone the repository from $repoUrl."
}

# Update PATH in the user environment
try {
    if ($env:Path -notmatch [regex]::Escape("$installDir\bin")) {
        [Environment]::SetEnvironmentVariable("Path", "$installDir\bin;$env:Path", [System.EnvironmentVariableTarget]::User)
        Log-Message "Updated PATH in user environment."
    } else {
        Log-Message "PATH already contains $installDir\bin."
    }
} catch {
    Error-Exit "Failed to update the PATH environment variable."
}

# Final message to the user
Log-Message "ServeJVM installed successfully. Restart your terminal or open a new one to start using it."
