# ServeJVM

ServeJVM is a powerful and intuitive Java Version Manager. It allows developers to easily install, switch, and manage multiple Java versions on their machines across Windows, Linux, and macOS platforms, streamlining your Java development environment with just a few simple commands.

## Features

- Install specific versions of Java with ease.
- Switch between different Java versions on the fly.
- List all installed Java versions.
- Uninstall Java versions you no longer need.
- Cross-platform support for Windows, Linux, and macOS.

## Installation

### Prerequisites

- **Git**: Ensure Git is installed on your system for cloning the repository.
- **cURL or Wget**: Required for Linux and macOS to download Java versions.
- **PowerShell**: Required for Windows users.

### Installation Instructions

#### Linux / macOS ( In development )

1. **Open your terminal**.
2. **Install ServeJVM using cURL or Wget**:

    Using `cURL`:
    ```bash
    curl -o- https://raw.githubusercontent.com/lowinn/ServeJVM/main/install.sh | bash
    ```

    Using `Wget`:
    ```bash
    wget -qO- https://raw.githubusercontent.com/lowinn/ServeJVM/main/install.sh | bash
    ```

3. **Restart your terminal**:

    Restart your terminal or run `source ~/.bashrc` (or `source ~/.zshrc` for Zsh) to apply the changes.

4. **Verify the installation**:

    Run the following command to verify that ServeJVM is installed correctly:

    ```bash
    jvm list
    ```

### Windows

1. **Open PowerShell Core (`pwsh`) as Administrator**:
    - Press `Windows + X` and choose **Windows Terminal (Admin)** if it defaults to PowerShell Core.
    - Alternatively, search for "pwsh" or "PowerShell 7" in the Start menu, right-click it, and select **Run as administrator**.
    - If you don't have PowerShell Core installed, you can download it from the official site: [Download PowerShell Core](https://github.com/PowerShell/PowerShell).

2. **Install ServeJVM using PowerShell Core**:

    ```powershell
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lowinn/ServeJVM/main/install.ps1" -OutFile "$env:TEMP\install.ps1"; & "$env:TEMP\install.ps1"
    ```

**Note**: It is highly recommended to use PowerShell Core (`pwsh`) instead of the original Windows PowerShell (`powershell.exe`) to avoid potential syntax and parsing issues that might occur with certain scripts.
"""
3. **Restart your terminal**:

    After running the script, restart your terminal or log out and back in to apply the changes.

4. **Verify the installation**:

    Run the following command to verify that ServeJVM is installed correctly:

    ```powershell
    jvm list
    ```

## Usage

ServeJVM provides a simple command-line interface for managing Java versions. Below are some common commands:

### Install a Java Version

To install a specific Java version, use:

```bash
jvm install <version>
```

For example, to install Java 11:

```bash
jvm install 11
```
### List Installed Java Versions

To list all installed Java versions, use:

```bash
jvm list
```
### Switch to a Java Version
To switch to a specific Java version, use:
```bash
jvm use <version>
```
For example, to switch to Java 11:
```bash
jvm use 11
```
### Uninstall a Java Version
To uninstall a specific Java version, use:
```bash
jvm uninstall <version>
```
For example, to uninstall Java 11:
```bash
jvm uninstall 11
```

### Contributing
We welcome contributions to ServeJVM! Please feel free to submit issues, fork the repository, and make pull requests.

### License
ServeJVM is licensed under the MIT License. See the LICENSE file for more information.

### Summary:

This markdown content is formatted for a `README.md` file, providing clear instructions on how to install and use ServeJVM across different platforms. It also includes sections on features, prerequisites, usage, contributing, and licensing.
