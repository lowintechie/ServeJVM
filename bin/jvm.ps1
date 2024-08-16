<#
.SYNOPSIS
    ServeJVM Command-Line Interface Script

.DESCRIPTION
    This PowerShell script is part of the ServeJVM system, which allows users to manage multiple Java versions on their machine.
    It provides functionality to install, use, list, and uninstall different versions of  Java.

    Author: LOWIN TECHIE
    Version: 1.0
    Date: 2024-08-16

    This script is part of the ServeJVM project, available at:
    https://github.com/lowinn/ServeJVM

    Please refer to the project's documentation for more details.

.LINK
    https://github.com/lowinn/ServeJVM
#>

param (
    [string]$command,
    [string]$version
)

# Define variables
$logFile = "$env:USERPROFILE\.serveJVM\jvm.log"
$repoUrl = "https://github.com/lowinn/ServeJVM.git"
$installDir = "$env:USERPROFILE\.serveJVM"
$serveJvmDir = "$installDir\ServeJVM"
$binDir = "$installDir\bin"
$scriptFile = "$binDir\jvm.ps1"
$logFile = "$installDir\install.log"
$versionFile = "$installDir\version.txt"
$currentVersion = "1.1"
$updateUrl = "https://raw.githubusercontent.com/lowinn/ServeJVM/main/install.ps1"
# Function to log messages
function Log-Message {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$level] - $message"
    Write-Output $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Function to handle errors
function Error-Exit {
    param (
        [string]$message
    )
    Log-Message "$message" "ERROR"
    Log-Message "Operation failed. Please check the log file at $logFile for more details." "ERROR"
    exit 1
}

function Install-Java {
    param (
        [string]$version
    )
    $installDir = "$env:USERPROFILE\.serveJVM\versions\$version"
    $tmpDir = "$env:USERPROFILE\.serveJVM\tmp"
    $tmpFile = "$tmpDir\corretto-$version.zip"
    $extractDir = "$tmpDir\extracted"

    try {
        # Ensure the tmp and extract directories exist
        if (-not (Test-Path -Path $tmpDir)) {
            New-Item -ItemType Directory -Force -Path $tmpDir -ErrorAction Stop | Out-Null
            Log-Message "Created temporary directory at $tmpDir."
        }
        if (-not (Test-Path -Path $extractDir)) {
            New-Item -ItemType Directory -Force -Path $extractDir -ErrorAction Stop | Out-Null
            Log-Message "Created extraction directory at $extractDir."
        }

        # Create the installation directory
        if (-not (Test-Path -Path $installDir)) {
            New-Item -ItemType Directory -Force -Path $installDir -ErrorAction Stop | Out-Null
            Log-Message "Created directory for Java $version at $installDir."
        }
    } catch {
        Error-Exit "Failed to create necessary directories for version $version."
    }

    $url = "https://corretto.aws/downloads/latest/amazon-corretto-$version-x64-windows-jdk.zip"
    try {
        Log-Message "Attempting to download from $url"

        # Enhanced curl command for faster download
        $curlCommand = "curl --ssl-no-revoke -L --max-time 180 --retry 3 --retry-delay 10 --speed-limit 100000 --speed-time 30 --output `"$tmpFile`" `"$url`""

        Invoke-Expression $curlCommand
        Log-Message "Downloaded  Java $version using curl."
    } catch {
        Log-Message "Failed to download  Java $version from $url. Error details: $_" "ERROR"
        Error-Exit "Check if the Java version $version exists and the URL is correct."
    }

    try {
        Expand-Archive -Path $tmpFile -DestinationPath $extractDir -ErrorAction Stop
        Log-Message "Extracted  Java $version to $extractDir."

        # Handle nested directory structure
        $extractedContent = Get-ChildItem -Path $extractDir | Select-Object -First 1
        if ($extractedContent -and (Test-Path "$extractDir\$($extractedContent.Name)\bin")) {
            # Move the contents of the extracted top-level folder to the install directory
            Move-Item -Path "$extractDir\$($extractedContent.Name)\*" -Destination $installDir -Force
            Log-Message "Moved extracted files to $installDir."
        } elseif ($extractedContent) {
            # If no nested directory structure, move all files directly
            Move-Item -Path "$extractDir\*" -Destination $installDir -Force
            Log-Message "Moved extracted files to $installDir."
        } else {
            Error-Exit "Extraction failed: no content found in the archive."
        }
    } catch {
        Log-Message "Failed to extract or move  Java $version." "ERROR"
        Error-Exit "Extraction or move operation failed. Ensure that the downloaded file is a valid ZIP archive."
    }

    try {
        Remove-Item $tmpFile -Force -ErrorAction Stop
        Remove-Item $extractDir -Recurse -Force -ErrorAction Stop
        Log-Message "Cleaned up temporary files."
    } catch {
        Log-Message "Failed to remove temporary files." "WARNING"
    }

    Log-Message " Java $version installed successfully."
}

# Function to stwitch to a specific Java version
function Use-Java {
    param (
        [string]$version
    )

    $installDir = "$env:USERPROFILE\.serveJVM\versions\$version"

    if (Test-Path $installDir) {
        try {
            # Start of the process
            Log-Message "Setting up  Java $version..."
            Write-Host "Setting up  Java $version..." -ForegroundColor Cyan

            $steps = 5
            $currentStep = 0

            function Update-Progress {
                param (
                    [string]$activity,
                    [int]$percentComplete
                )
                $currentStep++
                Write-Progress -Activity $activity -Status "$percentComplete% Complete" -PercentComplete $percentComplete
            }
            # Step 1: Set JAVA_HOME
            Update-Progress -activity "Setting JAVA_HOME" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Setting JAVA_HOME to $installDir"
            [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $installDir, [System.EnvironmentVariableTarget]::User)

            # Step 2: Retrieve current PATH
            Update-Progress -activity "Retrieving PATH" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Retrieving PATH."
            $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Step 3: Clean up old PATH entries
            Update-Progress -activity "Cleaning old PATH entries" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Cleaning old PATH entries."
            $newPath = ($currentPath -split ';') -notmatch [regex]::Escape('\.serveJVM\versions\\') -join ';'

            # Step 4: Update PATH with new Java version
            Update-Progress -activity "Updating PATH" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Adding $installDir\bin to PATH."
            $newPath = "$installDir\bin;$newPath"
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::User)

            # Step 5: Update session variables
            Update-Progress -activity "Updating session variables" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Updating session JAVA_HOME and PATH."
            $env:JAVA_HOME = $installDir
            $env:Path = "$installDir\bin;" + ($env:Path -replace [regex]::Escape("$env:JAVA_HOME\bin;"), "")

            Write-Progress -Activity "Setup Complete" -Status "100% Complete" -PercentComplete 100
            Write-Host "Switched to Java $version successfully." -ForegroundColor Green
            Log-Message "Switched to Java $version."
            Write-Output "Switched to Java $version. Please restart your terminal session or run 'refreshenv' if using a tool like Chocolatey."
            } catch {
                Write-Host "Failed to set environment variables for Java $version." -ForegroundColor Red
                Log-Message "Failed to set variables for Java $version. Error: $_" "ERROR"
                Error-Exit "Failed to set environment variables."
            }}else {
                Write-Host " Java version $version is not installed." -ForegroundColor Red
                Log-Message " Java version $version is not installed." "ERROR"
                Error-Exit " Java version $version is not installed."
            }
    }


# List installed versions
function List-Java {
    try {
        $versions = Get-ChildItem -Directory "$env:USERPROFILE\.serveJVM\versions" | ForEach-Object { $_.Name }
        if ($versions) {
            Write-Host "📂 Installed Java Versions:" -ForegroundColor Cyan
            $versions | ForEach-Object {
                Write-Host "  ➡️ $($_)" -ForegroundColor Green
            }
        } else {
            Write-Host "⚠️ No Java versions installed." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Failed to list Java versions." -ForegroundColor Red
        Log-Message "Error listing Java versions. Error: $_" "ERROR"
        Error-Exit "Failed to list Java versions."
    }
}

# Uninstall a specific Java version
function Uninstall-Java {
    param (
        [string]$version
    )
    $installDir = "$env:USERPROFILE\.serveJVM\versions\$version"

    if (Test-Path $installDir) {
        try {
            # Remove the installation directory
            Remove-Item -Recurse -Force $installDir -ErrorAction Stop
            Log-Message " Java $version uninstalled successfully."
            Write-Output " Java $version uninstalled successfully."

            # Clear JAVA_HOME if it is pointing to the uninstalled version
            $currentJavaHome = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", [System.EnvironmentVariableTarget]::User)
            if ($currentJavaHome -eq $installDir) {
                [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $null, [System.EnvironmentVariableTarget]::User)
                Log-Message "Cleared JAVA_HOME environment variable."
                Write-Output "Cleared JAVA_HOME environment variable."
            }

            # Remove the Java bin directory from the PATH variable
            $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
            $newPath = ($currentPath -split ';') -notmatch [regex]::Escape("$installDir\bin") -join ';'
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::User)
            Log-Message "Removed $installDir\bin from PATH environment variable."
            Write-Output "Removed $installDir\bin from PATH environment variable."

            # Clear the current session's environment variables if they were set to the uninstalled version
            if ($env:JAVA_HOME -eq $installDir) {
                $env:JAVA_HOME = $null
                $env:Path = $env:Path -replace [regex]::Escape("$installDir\bin;"), ""
                Log-Message "Cleared JAVA_HOME and updated PATH for the current session."
                Write-Output "Cleared JAVA_HOME and updated PATH for the current session."
            }
        } catch {
            Log-Message "Failed to uninstall  Java $version. Error: $_" "ERROR"
            Error-Exit "Failed to uninstall  Java $version. Please ensure the directory is not in use."
        }
    } else {
        Error-Exit " Java version $version is not installed."
    }
}

# Function to check for updates
function Check-For-Updates {
    Write-Host "Checking for updates..." -ForegroundColor Cyan
    try {
        $latestVersion = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/lowinn/ServeJVM/main/version.txt" -ErrorAction Stop
        if ($currentVersion -ne $latestVersion) {
            Write-Host "New version available: $latestVersion" -ForegroundColor Yellow
            Write-Host "Run 'jvm update' to update to the latest version." -ForegroundColor Yellow
        } else {
            Write-Host "You are using the latest version of ServeJVM." -ForegroundColor Green
        }
    } catch {
        Write-Host "Failed to check for updates." -ForegroundColor Red
    }
}

# Function to update ServeJVM
function Update-ServeJVM {
    Write-Host "Updating ServeJVM..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $updateUrl -OutFile "$env:TEMP\install.ps1" -ErrorAction Stop
        & "$env:TEMP\install.ps1"
        Write-Host "ServeJVM updated successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to update ServeJVM." -ForegroundColor Red
    }
}

# Function to print help/usage information
function Show-Usage {
    Write-Host "ServeJVM Command-Line Interface" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host "Usage: jvm <command> [...args]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  install   [command]               Install the specified Java version." -ForegroundColor Green
    Write-Host "  use       [command]               Switch to the specified Java version." -ForegroundColor Green
    Write-Host "  list      [command]               List all installed Java versions." -ForegroundColor Green
    Write-Host "  uninstall [command]               Uninstall the specified Java version." -ForegroundColor Green
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Cyan
    Write-Host "  jvm install 11" -ForegroundColor Yellow
    Write-Host "  jvm use 11" -ForegroundColor Yellow
    Write-Host "  jvm list" -ForegroundColor Yellow
    Write-Host "  jvm uninstall 11" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Learn more about ServeJVM: https://github.com/lowinn/ServeJVM/blob/main/README.md" -ForegroundColor Magenta
}

# Enhanced CLI Interface
switch ($command) {
    "install" {
        if ($version) {
            Write-Host "Installing Java $version..." -ForegroundColor Cyan
            Install-Java -version $version
            Write-Host "Installation complete." -ForegroundColor Green
        } else {
            Write-Host "Error: Missing version parameter." -ForegroundColor Red
            Show-Usage
        }
    }
    "use" {
        if ($version) {
            Write-Host "Switching to Java $version..." -ForegroundColor Cyan
            Use-Java -version $version
            Write-Host "Switched to Java $version." -ForegroundColor Green
        } else {
            Write-Host "Error: Missing version parameter." -ForegroundColor Red
            Show-Usage
        }
    }
    "list" {
        List-Java
    }
    "uninstall" {
        if ($version) {
            Write-Host "Uninstalling Java $version..." -ForegroundColor Cyan
            Uninstall-Java -version $version
            Write-Host "Uninstallation complete." -ForegroundColor Green
        } else {
            Write-Host "Error: Missing version parameter." -ForegroundColor Red
            Show-Usage
        }
    }
    "update" {
       Update-ServeJVM
    }
    default {
        Check-For-Updates
        Show-Usage
    }
}


