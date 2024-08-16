#!/bin/bash
# -----------------------------------------------------------------------------
# SYNOPSIS
#     ServeJVM Command-Line Interface Script
#
# DESCRIPTION
#     This script manages multiple Java versions using ServeJVM on Unix-based
#     systems. It allows you to install, use, list, and uninstall different
#     versions of Amazon Corretto Java.
#
# NOTES
#     Author: LOWIN TECHIE
#     Version: 1.0
#     Date: 2024-08-16
# -----------------------------------------------------------------------------

# Log file location
LOG_FILE="$HOME/.jvm_manager/jvm-manager.log"

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

# Detect OS function
detect_os() {
    case "$(uname -s)" in
        Linux*)     os=Linux;;
        Darwin*)    os=Mac;;
        CYGWIN*)    os=Cygwin;;
        MINGW*)     os=MinGw;;
        *)          os="UNKNOWN:${unameOut}"
    esac
    echo ${os}
}

# Install Java function
install_java() {
    version=$1
    mkdir -p "$HOME/.jvm_manager/versions/$version" || error_exit "Failed to create directory for version $version."
    if curl -o "$HOME/.jvm_manager/tmp/openjdk-$version.tar.gz" "https://link-to-java-distribution/$version/openjdk-$version.tar.gz" 2>>"$LOG_FILE"; then
        log_message "Downloaded Java $version."
    else
        error_exit "Failed to download Java $version."
    fi

    if tar -xzf "$HOME/.jvm_manager/tmp/openjdk-$version.tar.gz" -C "$HOME/.jvm_manager/versions/$version" --strip-components=1 2>>"$LOG_FILE"; then
        log_message "Extracted Java $version."
    else
        error_exit "Failed to extract Java $version."
    fi

    rm "$HOME/.jvm_manager/tmp/openjdk-$version.tar.gz"
    log_message "Java $version installed successfully."
}

# Use Java function
use_java() {
    version=$1
    if [ -d "$HOME/.jvm_manager/versions/$version" ]; then
        export JAVA_HOME="$HOME/.jvm_manager/versions/$version"
        export PATH="$JAVA_HOME/bin:$PATH"
        log_message "Switched to Java $version."
    else
        error_exit "Java version $version is not installed."
    fi
}

# List installed versions
list_java() {
    if [ -d "$HOME/.jvm_manager/versions/" ]; then
        ls "$HOME/.jvm_manager/versions/"
        log_message "Listed installed Java versions."
    else
        log_message "No Java versions installed."
    fi
}

# Uninstall Java version
uninstall_java() {
    version=$1
    if [ -d "$HOME/.jvm_manager/versions/$version" ]; then
        rm -rf "$HOME/.jvm_manager/versions/$version"
        log_message "Java $version uninstalled."
    else
        error_exit "Java version $version is not installed."
    fi
}

 CLI Interface
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
        if [ -z "$JAVA_HOME" ]; then
            echo "No Java version is currently active."
            log_message "No active Java version found."
        else
            echo "Current active Java version: $JAVA_HOME"
            log_message "Displayed current active Java version: $JAVA_HOME."
        fi
        ;;

    help|--help|-h)
        echo "Usage: jvm <command> [...args]"
        echo
        echo "Commands:"
        echo "  install    11                  Install a specific Java version (e.g., jvm install 11)"
        echo "  use        17                  Switch to a specific Java version (e.g., jvm use 17)"
        echo "  list                            List all installed Java versions"
        echo "  uninstall  8                   Uninstall a specific Java version (e.g., jvm uninstall 8)"
        echo "  current                         Show the currently active Java version"
        echo
        echo "  help                            Show this help text"
        echo
        echo "Learn more about ServeJVM:       https://github.com/lowinn/ServeJVM/blob/main/README.md"
        echo "Join our Community:              https://github.com/lowinn/ServeJVM/discussions"
        ;;

    *)
        echo "Invalid command: $1"
        echo "Type 'jvm help' to see all available commands."
        log_message "Invalid command used: $1"
        ;;
esac
