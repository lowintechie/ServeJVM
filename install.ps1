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
$repoUrl = "https://github.com/lowinn/ServeJVM/archive/refs/heads/main.zip"
$installDir = "$env:USERPROFILE\.serveJVM"
$serveJvmDir = "$installDir\ServeJVM"
$binDir = "$installDir\bin"
$logFile = "$installDir\install.log"
$zipFile = "$env:TEMP\ServeJVM.zip"
$tmpDir = "$installDir\tmp"
$versionsDir = "$installDir\versions"

# Check if script execution is allowed
$executionPolicy = Get-ExecutionPolicy

if ($executionPolicy -eq "Restricted" -or $executionPolicy -eq "AllSigned") {
    try {
        # Attempt to set the execution policy to Bypass temporarily
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
            Start-Sleep -Milliseconds 500  # Wait to ensure the directory is fully created
            if (-not (Test-Path -Path $dir)) {
                throw "Directory $dir could not be created."
            }
            Write-Output "Created directory at $dir."
        }
    }
} catch {
    Write-Output "ERROR: Failed to create necessary directories. $_"
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

# Download the repository zip file using curl
try {
    $curlCommand = "curl -L -o `"$zipFile`" `"$repoUrl`""
    Invoke-Expression $curlCommand
} catch {
    Error-Exit "Failed to download the repository from $repoUrl."
}

# Extract the downloaded zip file
try {
    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installDir)
    Remove-Item -Force $zipFile  # Clean up the zip file
} catch {
    Error-Exit "Failed to extract the repository from $zipFile."
}

# Move the extracted files to the proper location
$extractedDir = "$installDir\ServeJVM-main"
try {
    if (Test-Path -Path $extractedDir) {
        # Move contents from the extracted directory, avoiding overwriting existing directories
        Get-ChildItem -Path "$extractedDir\*" -Recurse | ForEach-Object {
            $destinationPath = Join-Path -Path $installDir -ChildPath $_.FullName.Substring($extractedDir.Length + 1)
            if (-not (Test-Path -Path $destinationPath)) {
                Move-Item -Path $_.FullName -Destination $destinationPath -Force
            }
        }
        Remove-Item -Recurse -Force $extractedDir
    } else {
        Error-Exit "The extracted directory does not exist."
    }
} catch {
    Error-Exit "Failed to move the extracted files to $installDir."
}

# Clean up by removing the ServeJVM folder
try {
    if (Test-Path -Path $serveJvmDir) {
        Remove-Item -Recurse -Force $serveJvmDir
    }
} catch {
    Write-Output "Failed to remove the ServeJVM folder. $_"
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

Log-Message "ServeJVM installed successfully. Restart your terminal or open a new one to start using it."

# Restore the original execution policy
if ($executionPolicy -ne "Restricted" -and $executionPolicy -ne "AllSigned") {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy $executionPolicy -Force
}

