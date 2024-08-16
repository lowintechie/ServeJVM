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
- **cURL**: Required for Linux and macOS to download Java versions.
- **PowerShell**: Required for Windows users.

### Installation Instructions

#### Linux / macOS

1. **Open your terminal**.
2. **Clone the ServeJVM repository**:

    ```bash
    git clone https://github.com/lowinn/ServeJVM.git $HOME/.serveJVM
    ```

3. **Run the installation script**:

    ```bash
    $HOME/.serveJVM/install.sh
    ```

4. **Update your PATH**:

    The installation script will automatically add ServeJVM to your PATH by modifying your `.bashrc`. If you're using a different shell (like Zsh), you may need to update the corresponding profile file (`.zshrc` for Zsh).

5. **Restart your terminal**:

    Restart your terminal or run `source ~/.bashrc` (or `source ~/.zshrc` for Zsh) to apply the changes.

6. **Verify the installation**:

    Run the following command to verify that ServeJVM is installed correctly:

    ```bash
    jvm-manager list
    ```

#### Windows

1. **Open PowerShell as Administrator**.
2. **Clone the ServeJVM repository**:

    ```powershell
    git clone https://github.com/lowinn/ServeJVM.git "$env:USERPROFILE\.serveJVM"
    ```

3. **Run the installation script**:

    ```powershell
    $env:USERPROFILE\.serveJVM\install.ps1
    ```

4. **Update your PATH**:

    The installation script will automatically update your PATH environment variable. You may need to restart your terminal or system for the changes to take effect.

5. **Verify the installation**:

    Run the following command to verify that ServeJVM is installed correctly:

    ```powershell
    jvm-manager list
    ```

## Usage

ServeJVM provides a simple command-line interface for managing Java versions. Below are some common commands:

### Install a Java Version

```bash
jvm-manager install <version>
