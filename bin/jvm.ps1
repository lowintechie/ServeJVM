param (
  [string]$command,
  [string]$version
)

# Define variables
$logFile = "$env:USERPROFILE\.jvm_manager\jvm-manager.log"

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
    Log-Message "Operation failed. Please check the log file at $logFile for more details."
    exit 1
}

# Install Java function
function Install-Java {
    param (
        [string]$version
    )
    $installDir = "$env:USERPROFILE\.jvm_manager\versions\$version"
    $tmpFile = "$env:USERPROFILE\.jvm_manager\tmp\openjdk-$version.zip"

    try {
        New-Item -ItemType Directory -Force -Path $installDir -ErrorAction Stop | Out-Null
        Log-Message "Created directory for Java $version at $installDir."
    } catch {
        Error-Exit "Failed to create directory for version $version."
    }

    $url = "https://link-to-java-distribution/$version/openjdk-$version.zip"
    try {
        Invoke-WebRequest -Uri $url -OutFile $tmpFile -ErrorAction Stop
        Log-Message "Downloaded Java $version."
    } catch {
        Error-Exit "Failed to download Java $version."
    }

    try {
        Expand-Archive -Path $tmpFile -DestinationPath $installDir -ErrorAction Stop
        Log-Message "Extracted Java $version."
    } catch {
        Error-Exit "Failed to extract Java $version."
    }

    try {
        Remove-Item $tmpFile -Force -ErrorAction Stop
        Log-Message "Removed temporary file $tmpFile."
    } catch {
        Error-Exit "Failed to remove temporary file $tmpFile."
    }

    Log-Message "Java $version installed successfully."
}

# Use Java function
function Use-Java {
    param (
        [string]$version
    )
    $installDir = "$env:USERPROFILE\.jvm_manager\versions\$version"
    if (Test-Path $installDir) {
        $env:JAVA_HOME = $installDir
        $env:Path = "$env:JAVA_HOME\bin;$env:Path"
        Log-Message "Switched to Java $version."
    } else {
        Error-Exit "Java version $version is not installed."
    }
}

# List installed versions
function List-Java {
    try {
        $versions = Get-ChildItem -Directory "$env:USERPROFILE\.jvm_manager\versions" | ForEach-Object { $_.Name }
        if ($versions) {
            $versions | ForEach-Object { Write-Output $_ }
            Log-Message "Listed installed Java versions."
        } else {
            Log-Message "No Java versions installed."
        }
    } catch {
        Error-Exit "Failed to list Java versions."
    }
}

# Uninstall Java version
function Uninstall-Java {
    param (
        [string]$version
    )
    $installDir = "$env:USERPROFILE\.jvm_manager\versions\$version"
    if (Test-Path $installDir) {
        try {
            Remove-Item -Recurse -Force $installDir -ErrorAction Stop
            Log-Message "Java $version uninstalled."
        } catch {
            Error-Exit "Failed to uninstall Java $version."
        }
    } else {
        Error-Exit "Java version $version is not installed."
    }
}

# CLI Interface
switch ($command) {
    "install" { Install-Java -version $version }
    "use" { Use-Java -version $version }
    "list" { List-Java }
    "uninstall" { Uninstall-Java -version $version }
    default {
        Write-Output "Usage: jvm-manager {install|use|list|uninstall} [version]"
        Log-Message "Invalid command used: $command"
    }
}
