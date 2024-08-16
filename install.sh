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
LOG_FILE="$INSTALL_DIR/install.log"

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
log_message "Starting ServeJVM installation..."

# Clone the repository
if git clone "$REPO_URL" "$INSTALL_DIR"; then
    log_message "Repository cloned successfully to $INSTALL_DIR."
else
    error_exit "Failed to clone the repository from $REPO_URL."
fi

# Update PATH
if ! grep -q "$INSTALL_DIR/bin" <<< "$PATH"; then
    echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
    log_message "Updated PATH in user environment."
else
    log_message "PATH already contains $INSTALL_DIR/bin."
fi

# Final message
log_message "ServeJVM installed successfully. Restart your terminal or source your .bashrc to start using it."
