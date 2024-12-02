# Pacman Database Repair Script

## Overview

This Bash script is designed to repair and reset the Pacman package manager database and keyring on Arch Linux or Arch-based distributions. It helps resolve issues related to database corruption, problematic mirror updates, or keyring problems.

## Features

- Remove Pacman database lock
- Clear sync databases
- Reset GnuPG keyring
- Reinitialize and repopulate Pacman keyring
- Synchronize and update packages

## Prerequisites

- Arch Linux or Arch-based distribution
- Root/sudo privileges
- Bash shell

## Usage
sudo ./Ppm_db_fixer.sh

### Options

- `-h`, `--help`: Display help information and usage instructions

## Caution

:warning: **Warning**: This script performs destructive operations on your Pacman database. Use with caution and only when experiencing persistent package management issues.

## What the Script Does

1. Checks for and removes Pacman database lock
2. Removes existing sync databases
3. Removes current GnuPG keyring
4. Initializes a new Pacman keyring
5. Populates the new keyring
6. Synchronizes and updates all packages

## Requirements

- Must be run with root/sudo privileges
- Requires an active internet connection

## Troubleshooting

If you encounter any issues:
- Ensure you have a stable internet connection
- Check your system's package repositories
- Verify sufficient disk space

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions, issues, and feature requests are welcome!
