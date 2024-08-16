#!/bin/bash

# Define variables
REPO_URL="https://github.com/lowinn/ServeJVM.git"
INSTALL_DIR="$HOME/.jvm"
LOG_FILE="$HOME/.jvm/install.log"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to handle errors
error_exit() {
    log_message "ERROR: $1"
    log_message "Installation failed. Please check the log file at $LOG_FILE for more details."
    exit 1
}

# Start the installation process
log_message "Starting ServeJVM installation..."

# Clone the repository
if git clone "$REPO_URL" "$INSTALL_DIR" 2>>"$LOG_FILE"; then
    log_message "Repository cloned successfully to $INSTALL_DIR."
else
    error_exit "Failed to clone the repository from $REPO_URL."
fi

# Update PATH in .bashrc
if grep -q "$INSTALL_DIR/bin" "$HOME/.bashrc"; then
    log_message "PATH already updated in .bashrc."
else
    echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
    log_message "Updated PATH in .bashrc."
fi

# Source .bashrc
if source "$HOME/.bashrc"; then
    log_message "Sourced .bashrc successfully."
else
    error_exit "Failed to source .bashrc. Please run 'source ~/.bashrc' manually."
fi

# Final message to the user
log_message "ServeJVM installed successfully. Restart your terminal or run 'source ~/.bashrc' to start using it."

# End of script
log_message "Installation completed."
