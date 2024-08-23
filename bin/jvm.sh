#!/bin/bash
# -----------------------------------------------------------------------------
# SYNOPSIS
#     ServeJVM Command-Line Interface Script
#
# DESCRIPTION
#     This script manages multiple Java versions using ServeJVM on Unix-based
#     systems. It allows you to install, use, list, and uninstall different
#     versions of  Java.
#
# NOTES
#     Author: LOWIN TECHIE
#     Version: 1.0
#     Date: 2024-08-16
# -----------------------------------------------------------------------------
# Define constants
LOG_FILE="$HOME/.jvm_manager/jvm-manager.log"
INSTALL_DIR="$HOME/.jvm_manager"
VERSIONS_DIR="$INSTALL_DIR/versions"
TMP_DIR="$INSTALL_DIR/tmp"
DOWNLOAD_DIR="$HOME/Downloads"
ARCHIVE_EXTENSION="tar.gz"
DOWNLOAD_URL_PREFIX="https://corretto.aws/downloads/latest/amazon-corretto"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to handle errors
error_exit() {
    log_message "ERROR: $1"
    log_message "Operation failed. Please check the log file at $LOG_FILE for more details."
    exit 1
}

# Ensure required directories exist with correct permissions
mkdir -p "$VERSIONS_DIR" "$TMP_DIR" "$DOWNLOAD_DIR" || error_exit "Failed to create necessary directories."
chmod -R 755 "$INSTALL_DIR" || error_exit "Failed to set permissions for $INSTALL_DIR."
chmod -R 755 "$DOWNLOAD_DIR" || error_exit "Failed to set permissions for $DOWNLOAD_DIR."

# Function to install Java
install_java() {
    version=$1
    version_dir="$VERSIONS_DIR/$version"
    archive_file="$DOWNLOAD_DIR/openjdk-$version.$ARCHIVE_EXTENSION"

    if [ -d "$version_dir" ]; then
        log_message "Java version $version is already installed."
        echo "Java version $version is already installed."
        return
    fi

    # Use the correct URL
    download_url="$DOWNLOAD_URL_PREFIX-$version-linux-x64-jdk.$ARCHIVE_EXTENSION"

    # Download the file
    if curl -Lo "$archive_file" "$download_url" 2>>"$LOG_FILE"; then
        log_message "Downloaded Java $version."
    else
        error_exit "Failed to download Java $version from $download_url."
    fi

    # Set permissions to ensure the file can be extracted
    chmod 644 "$archive_file" || error_exit "Failed to set permissions for the downloaded file."

    # Extract the file
    if tar -xzf "$archive_file" -C "$TMP_DIR" 2>>"$LOG_FILE"; then
        mv "$TMP_DIR/$(ls "$TMP_DIR")" "$version_dir"
        chmod -R 755 "$version_dir" || error_exit "Failed to set permissions for the extracted files."
        log_message "Extracted Java $version."
    else
        error_exit "Failed to extract Java $version."
    fi

    rm -f "$archive_file"
    log_message "Java $version installed successfully."
    echo "Java $version installed successfully."
}

# Function to switch Java version
use_java() {
    version=$1
    version_dir="$VERSIONS_DIR/$version"

    if [ -d "$version_dir" ]; then
        export JAVA_HOME="$version_dir"
        export PATH="$JAVA_HOME/bin:$PATH"
        log_message "Switched to Java $version."
        echo "Switched to Java $version."
    else
        error_exit "Java version $version is not installed."
    fi
}

# Function to list installed Java versions
list_java() {
    if [ -d "$VERSIONS_DIR" ]; then
        ls "$VERSIONS_DIR"
        log_message "Listed installed Java versions."
    else
        log_message "No Java versions installed."
        echo "No Java versions installed."
    fi
}

# Function to uninstall Java version
uninstall_java() {
    version=$1
    version_dir="$VERSIONS_DIR/$version"

    if [ -d "$version_dir" ]; then
        rm -rf "$version_dir"
        log_message "Java $version uninstalled."
        echo "Java $version uninstalled."
    else
        error_exit "Java version $version is not installed."
    fi
}

# Function to display current Java version
current_java() {
    if [ -z "$JAVA_HOME" ]; then
        echo "No Java version is currently active."
        log_message "No active Java version found."
    else
        echo "Current active Java version: $JAVA_HOME"
        log_message "Displayed current active Java version: $JAVA_HOME."
    fi
}

# Function to show help/usage information
show_help() {
    echo "Usage: jvm <command> [...args]"
    echo
    echo "Commands:"
    echo "  install    <version>           Install a specific Java version (e.g., jvm install 11)"
    echo "  use        <version>           Switch to a specific Java version (e.g., jvm use 17)"
    echo "  list                           List all installed Java versions"
    echo "  uninstall  <version>           Uninstall a specific Java version (e.g., jvm uninstall 8)"
    echo "  current                        Show the currently active Java version"
    echo
    echo "  help                           Show this help text"
    echo
    echo "Learn more about ServeJVM:       https://github.com/lowinn/ServeJVM/blob/main/README.md"
    echo "Join our Community:              https://github.com/lowinn/ServeJVM/discussions"
}

# CLI Interface
case "$1" in
    install)
        if [ -z "$2" ]; then
            echo "Error: No version specified."
            echo "Usage: jvm install <version>"
            log_message "Failed attempt to install Java: No version specified."
        else
            install_java "$2"
        fi
        ;;

    use)
        if [ -z "$2" ]; then
            echo "Error: No version specified."
            echo "Usage: jvm use <version>"
            log_message "Failed attempt to use Java: No version specified."
        else
            use_java "$2"
        fi
        ;;

    list)
        list_java
        ;;

    uninstall)
        if [ -z "$2" ]; then
            echo "Error: No version specified."
            echo "Usage: jvm uninstall <version>"
            log_message "Failed attempt to uninstall Java: No version specified."
        else
            uninstall_java "$2"
        fi
        ;;

    current)
        current_java
        ;;

    help|--help|-h)
        show_help
        ;;

    *)
        echo "Invalid command: $1"
        echo "Type 'jvm help' to see all available commands."
        log_message "Invalid command used: $1"
        ;;
esac
