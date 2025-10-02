# Pentesting Tools Installation Script

## About

This script automates the installation of a wide range of penetration testing tools on a Debian-based Linux distribution. It is designed to be flexible and customizable, allowing users to select which tools and categories of tools to install via a simple JSON configuration file.

## Features

- **Customizable Installation**: Use the `tools_config.json` file to select which tools and categories to install.
- **Isolated Python Environments**: Python-based tools are installed using `pipx` to prevent dependency conflicts.
- **Automatic Shell Detection**: The script automatically detects your shell (bash, zsh, fish) and updates the correct configuration file.
- **Go and Python Installation**: Installs specified versions of Go and Python.
- **Virtual Environment Support**: Optionally creates a dedicated Python virtual environment for tools that are not installed via `pipx`.
- **Installation Report**: Generates a detailed report of the installed tools.

## Usage

To run the script, use the following command:

```bash
sudo bash install_pentest_tools.sh
```

The script needs to be run with `sudo` because it installs packages using `apt` and writes to system directories.

## Configuration

The installation is controlled by the `tools_config.json` file. You can edit this file to enable or disable the installation of individual tools or entire categories of tools.

### Tool Categories

The `tools_config.json` file is organized into categories, such as `web_application`, `reconnaissance`, `cloud_security`, etc. You can enable or disable a whole category by setting the `"enabled"` flag to `true` or `false`.

### Individual Tools

Within each category, you can enable or disable individual tools by setting their `"enabled"` flag.

### Installation Types

The script supports several installation types:

- `apt`: Installs the tool using the `apt` package manager.
- `go`: Installs the tool using `go install`.
- `pipx`: Installs Python-based tools in isolated environments using `pipx`.
- `custom`: Installs the tool using a custom shell command defined in the `install_cmd` field.

## Post-Installation

After the script has finished, you may need to open a new terminal or source your shell's configuration file for the changes to take effect. The script will automatically detect your shell and modify the appropriate file (`.bashrc`, `.zshrc`, etc.).

For example, if you are using `zsh`, you would run:

```bash
source ~/.zshrc
```

An installation report will be generated at `install_report.txt` in the script's directory.