#!/bin/bash
# -----------------------------------------------------------------------------
# SYNOPSIS
#     Installation script for ServeJVM.
#
# DESCRIPTION
#     This script clones the ServeJVM repository, updates the PATH environment
#     variable, and sets up ServeJVM for use on Unix-based systems.
#
# NOTES
#     Author: LOWIN TECHIE
#     Version: 1.0
#     Date: 2024-08-16
# -----------------------------------------------------------------------------

# Define variables
REPO_URL="https://github.com/lowinn/ServeJVM.git"
INSTALL_DIR="$HOME/.serveJVM"
BIN_DIR="$INSTALL_DIR/bin"
TMP_DIR="$INSTALL_DIR/tmp"
VERSIONS_DIR="$INSTALL_DIR/versions"
LOG_FILE="$INSTALL_DIR/install.log"
EXTRACTED_DIR="$HOME/ServeJVM-main"
BRANCH="main"  # Specify the branch to clone

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Function to handle errors
error_exit() {
    local message="$1"
    log_message "ERROR: $message"
    log_message "Installation failed. Please check the log file at $LOG_FILE for more details."
    exit 1
}

# Start installation
log_message "Starting ServeJVM installation from branch '$BRANCH'..."

# Ensure necessary directories exist
mkdir -p "$BIN_DIR" "$TMP_DIR" "$VERSIONS_DIR" || error_exit "Failed to create necessary directories."

# Clone the repository from the specified branch
log_message "Cloning the repository from $REPO_URL (branch: $BRANCH)..."
if [ -d "$EXTRACTED_DIR" ]; then
    rm -rf "$EXTRACTED_DIR"
fi

if git clone --branch "$BRANCH" "$REPO_URL" "$EXTRACTED_DIR"; then
    log_message "Repository cloned successfully to $EXTRACTED_DIR."
else
    error_exit "Failed to clone the repository from $REPO_URL (branch: $BRANCH)."
fi

# Copy only the required files and directories to the install directory
log_message "Copying necessary files from the cloned repository..."
cp "$EXTRACTED_DIR/bin/jvm.sh" "$BIN_DIR" || error_exit "Failed to copy jvm.sh."
cp "$EXTRACTED_DIR/version.txt" "$INSTALL_DIR" || error_exit "Failed to copy version.txt."

# Clean up the cloned repository directory
log_message "Cleaning up the cloned repository directory..."
rm -rf "$EXTRACTED_DIR" || log_message "Warning: Failed to clean up the cloned repository directory."

# Update PATH in the user environment
if ! grep -q "$BIN_DIR" <<< "$PATH"; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$HOME/.bashrc"
    log_message "Updated PATH in user environment."
else
    log_message "PATH already contains $BIN_DIR."
fi

# Final message
log_message "ServeJVM installed successfully from branch '$BRANCH'."
echo "ServeJVM installed successfully from branch '$BRANCH'. Restart your terminal or source your .bashrc to start using it."
