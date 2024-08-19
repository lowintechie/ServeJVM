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
$repoUrl = "https://github.com/lowinn/ServeJVM.git"
$installDir = "$env:USERPROFILE\.serveJVM"
$binDir = "$installDir\bin"
$tmpDir = "$installDir\tmp"
$versionsDir = "$installDir\versions"
$logFile = "$installDir\install.log"
$extractedDir = "C:\ServeJVM-main"

# Check if script execution is allowed
$executionPolicy = Get-ExecutionPolicy

if ($executionPolicy -eq "Restricted" -or $executionPolicy -eq "AllSigned") {
    try {
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    } catch {
        Write-Error "Failed to set execution policy to Bypass. Please run this script with elevated permissions or change the execution policy manually."
        exit 1
    }
}

# Ensure the necessary directories exist
try {
    $directories = @($binDir, $tmpDir, $versionsDir)
    foreach ($dir in $directories) {
        if (-not (Test-Path -Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Start-Sleep -Milliseconds 500
            if (-not (Test-Path -Path $dir)) {
                throw "Directory $dir could not be created."
            }
            Log-Message "Created directory at $dir."
        }
    }
} catch {
    Error-Exit "Failed to create necessary directories. $_"
}

# Function to log messages
function Log-Message {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$level] - $message"
    Add-Content -Path $logFile -Value $logEntry
}

# Function to handle errors
function Error-Exit {
    param (
        [string]$message
    )
    Log-Message "$message" "ERROR"
    Log-Message "Installation failed. Please check the log file at $logFile for more details." "ERROR"
    Write-Host -ForegroundColor Red "ERROR: $message"
    Write-Host -ForegroundColor Red "Installation failed. Please check the log file at $logFile for more details."
    exit 1
}

# Start the installation process
Log-Message "Starting ServeJVM installation..."
Write-Host -ForegroundColor Cyan "Starting ServeJVM installation..."

# Clone the repository using git
try {
    Log-Message "Cloning the repository from $repoUrl..."
    Write-Host -ForegroundColor Yellow "Cloning the ServeJVM repository..."
    if (Test-Path $extractedDir) {
        Remove-Item -Recurse -Force $extractedDir
    }
    git clone $repoUrl $extractedDir | Out-Null
} catch {
    Error-Exit "Failed to clone the repository from $repoUrl."
}

# Check if the clone was successful
if (-not (Test-Path -Path "$extractedDir\.git")) {
    Error-Exit "The repository was not cloned successfully."
}

# Copy only the required files and directories to the install directory
try {
    Copy-Item -Path "$extractedDir\bin\jvm.ps1" -Destination $binDir -Force
    Copy-Item -Path "$extractedDir\version.txt" -Destination $installDir -Force
    Log-Message "Copied necessary files from the cloned repository."
} catch {
    Error-Exit "Failed to copy necessary files from the cloned repository."
}

# Clean up the cloned repository directory
try {
    Remove-Item -Recurse -Force $extractedDir
    Log-Message "Cleaned up the cloned repository directory."
} catch {
    Log-Message "Failed to clean up the cloned repository directory. $_"
}

# Update PATH in the user environment
try {
    if ($env:Path -notmatch [regex]::Escape("$binDir")) {
        [Environment]::SetEnvironmentVariable("Path", "$binDir;$env:Path", [System.EnvironmentVariableTarget]::User)
        Log-Message "Updated PATH in user environment."
        Write-Host -ForegroundColor Green "PATH updated to include ServeJVM."
    } else {
        Log-Message "PATH already contains $binDir."
        Write-Host -ForegroundColor Yellow "PATH already contains ServeJVM."
    }
} catch {
    Error-Exit "Failed to update the PATH environment variable."
}

Log-Message "ServeJVM installed successfully."
Write-Host -ForegroundColor Green "ServeJVM installed successfully. Restart your terminal or open a new one to start using it."










