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
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Function to handle errors
function Error-Exit {
    param (
        [string]$message
    )
    Log-Message "ERROR: $message" -ForegroundColor Red
    Log-Message "Installation failed. Please check the log file at $logFile for more details." -ForegroundColor Red
    exit 1
}

# Check if Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Error-Exit "Git is not installed or not found in PATH. Please install Git and try again."
}

# Start the installation process
Log-Message "Starting ServeJVM installation..." -ForegroundColor Cyan

# Create the installation directory if it doesn't exist
try {
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Log-Message "Created installation directory at $installDir."
    } else {
        Log-Message "Installation directory already exists at $installDir."
    }
} catch {
    Error-Exit "Failed to create installation directory at $installDir."
}

# Clone the repository
try {
    git clone $repoUrl $installDir 2>>$logFile
    Log-Message "Repository cloned successfully to $installDir." -ForegroundColor Green
} catch {
    Error-Exit "Failed to clone the repository from $repoUrl."
}

# Update PATH in the user environment
try {
    if ($env:Path -notmatch [regex]::Escape("$installDir\bin")) {
        $env:Path = "$installDir\bin;$env:Path"
        [Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::User)
        Log-Message "Updated PATH in user environment." -ForegroundColor Green
    } else {
        Log-Message "PATH already contains $installDir\bin." -ForegroundColor Yellow
    }
} catch {
    Error-Exit "Failed to update the PATH environment variable."
}

# Final message to the user
Log-Message "ServeJVM installed successfully. Restart your terminal or open a new one to start using it." -ForegroundColor Green

# End of script
Log-Message "Installation completed." -ForegroundColor Cyan
