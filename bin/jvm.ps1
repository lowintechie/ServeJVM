param (
    [string]$command,
    [string]$version
)

# Define variables
$logFile = "$env:USERPROFILE\.jvm\jvm.log"

# Function to log messages
function Log-Message {
    param (
        [string]$message,
        [string]$level = "INFO"  # Default level is INFO
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
    $installDir = "$env:USERPROFILE\.jvm\versions\$version"
    $tmpDir = "$env:USERPROFILE\.jvm\tmp"
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

        # Execute the command
        Invoke-Expression $curlCommand
        Log-Message "Downloaded Amazon Corretto Java $version using curl."
    } catch {
        Log-Message "Failed to download Amazon Corretto Java $version from $url. Error details: $_" "ERROR"
        Error-Exit "Check if the Java version $version exists and the URL is correct."
    }

    try {
        Expand-Archive -Path $tmpFile -DestinationPath $extractDir -ErrorAction Stop
        Log-Message "Extracted Amazon Corretto Java $version to $extractDir."

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
        Log-Message "Failed to extract or move Amazon Corretto Java $version." "ERROR"
        Error-Exit "Extraction or move operation failed. Ensure that the downloaded file is a valid ZIP archive."
    }

    try {
        Remove-Item $tmpFile -Force -ErrorAction Stop
        Remove-Item $extractDir -Recurse -Force -ErrorAction Stop
        Log-Message "Cleaned up temporary files."
    } catch {
        Log-Message "Failed to remove temporary files." "WARNING"
    }

    Log-Message "Amazon Corretto Java $version installed successfully."
}


function Use-Java {
    param (
        [string]$version
    )

    $installDir = "$env:USERPROFILE\.jvm\versions\$version"

    if (Test-Path $installDir) {
        try {
            # Start of the process
            Log-Message "Setting up Amazon Corretto Java $version..."
            Write-Host "Setting up Amazon Corretto Java $version..." -ForegroundColor Cyan

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
            Update-Progress -activity "Setting JAVA_HOME environment variable" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Setting JAVA_HOME environment variable to $installDir"
            [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $installDir, [System.EnvironmentVariableTarget]::User)

            # Step 2: Retrieve current PATH
            Update-Progress -activity "Retrieving current PATH environment variable" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Retrieving current PATH environment variable."
            $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Step 3: Clean up old PATH entries
            Update-Progress -activity "Cleaning up old JAVA_HOME\bin entries from PATH" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Cleaning up old JAVA_HOME\bin entries from PATH."
            $newPath = ($currentPath -split ';') -notmatch [regex]::Escape('\.jvm\versions\\') -join ';'

            # Step 4: Update PATH with new Java version
            Update-Progress -activity "Adding new JAVA_HOME\bin to PATH" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Adding $installDir\bin to the PATH environment variable."
            $newPath = "$installDir\bin;$newPath"
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::User)

            # Step 5: Update session variables
            Update-Progress -activity "Updating JAVA_HOME and PATH for the current session" -percentComplete ($currentStep / $steps * 100)
            Log-Message "Updating JAVA_HOME and PATH for the current session."
            $env:JAVA_HOME = $installDir
            $env:Path = "$installDir\bin;" + ($env:Path -replace [regex]::Escape("$env:JAVA_HOME\bin;"), "")

            Write-Progress -Activity "Setup Complete" -Status "100% Complete" -PercentComplete 100
            Write-Host "Switched to Amazon Corretto Java $version successfully." -ForegroundColor Green
            Log-Message "Switched to Amazon Corretto Java $version successfully."
            Write-Output "Switched to Amazon Corretto Java $version. Please restart your terminal session or run 'refreshenv' if using a tool like Chocolatey."
        } catch {
            Write-Host "Failed to set environment variables for Amazon Corretto Java $version." -ForegroundColor Red
            Log-Message "Failed to set environment variables for Amazon Corretto Java $version. Error: $_" "ERROR"
            Error-Exit "Failed to set environment variables."
        }
    } else {
        Write-Host "Amazon Corretto Java version $version is not installed." -ForegroundColor Red
        Log-Message "Amazon Corretto Java version $version is not installed." "ERROR"
        Error-Exit "Amazon Corretto Java version $version is not installed."
    }
}




# List installed versions
function List-Java {
    try {
        $versions = Get-ChildItem -Directory "$env:USERPROFILE\.jvm\versions" | ForEach-Object { $_.Name }
        if ($versions) {
            $versions | ForEach-Object { Write-Output $_ }
            Log-Message "Listed installed Amazon Corretto Java versions."
        } else {
            Log-Message "No Amazon Corretto Java versions installed."
        }
    } catch {
        Error-Exit "Failed to list Amazon Corretto Java versions."
    }
}

function Uninstall-Java {
    param (
        [string]$version
    )
    $installDir = "$env:USERPROFILE\.jvm\versions\$version"

    if (Test-Path $installDir) {
        try {
            # Remove the installation directory
            Remove-Item -Recurse -Force $installDir -ErrorAction Stop
            Log-Message "Amazon Corretto Java $version uninstalled successfully."
            Write-Output "Amazon Corretto Java $version uninstalled successfully."

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
            Log-Message "Failed to uninstall Amazon Corretto Java $version. Error: $_" "ERROR"
            Error-Exit "Failed to uninstall Amazon Corretto Java $version. Please ensure the directory is not in use."
        }
    } else {
        Error-Exit "Amazon Corretto Java version $version is not installed."
    }
}


# Function to print help/usage information
function Show-Usage {
    Write-Host "ServeJVM Command-Line Interface" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host "Usage: jvm {install|use|list|uninstall} [version]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  install   [version]  - Install the specified Java version." -ForegroundColor Green
    Write-Host "  use       [version]  - Switch to the specified Java version." -ForegroundColor Green
    Write-Host "  list                  - List all installed Java versions." -ForegroundColor Green
    Write-Host "  uninstall [version]  - Uninstall the specified Java version." -ForegroundColor Green
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Cyan
    Write-Host "  jvm install 11" -ForegroundColor Yellow
    Write-Host "  jvm use 11" -ForegroundColor Yellow
    Write-Host "  jvm list" -ForegroundColor Yellow
    Write-Host "  jvm uninstall 11" -ForegroundColor Yellow
    Write-Host ""
}

# Enhanced CLI Interface
switch ($command) {
    "install" {
        if ($version) {
            Write-Host "Installing Amazon Corretto Java $version..." -ForegroundColor Cyan
            Install-Java -version $version
            Write-Host "Installation complete." -ForegroundColor Green
        } else {
            Write-Host "Error: Missing version parameter." -ForegroundColor Red
            Show-Usage
        }
    }
    "use" {
        if ($version) {
            Write-Host "Switching to Amazon Corretto Java $version..." -ForegroundColor Cyan
            Use-Java -version $version
            Write-Host "Switched to Java $version." -ForegroundColor Green
        } else {
            Write-Host "Error: Missing version parameter." -ForegroundColor Red
            Show-Usage
        }
    }
    "list" {
        Write-Host "Listing all installed Java versions..." -ForegroundColor Cyan
        List-Java
    }
    "uninstall" {
        if ($version) {
            Write-Host "Uninstalling Amazon Corretto Java $version..." -ForegroundColor Cyan
            Uninstall-Java -version $version
            Write-Host "Uninstallation complete." -ForegroundColor Green
        } else {
            Write-Host "Error: Missing version parameter." -ForegroundColor Red
            Show-Usage
        }
    }
    default {
        Write-Host "Error: Invalid command '$command'." -ForegroundColor Red
        Log-Message "Invalid command used: $command" "ERROR"
        Show-Usage
    }
}

