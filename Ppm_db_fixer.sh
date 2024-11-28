#!/usr/bin/env bash

# Script to repair Pacman package manager database and keyring issues
# Useful after problematic mirror updates or database corruption

set -euo pipefail  # Improved error handling
# -e: exit on error
# -u: treat unset variables as an error
# -o pipefail: ensure pipeline errors are captured

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;36m'
NC='\033[0m' # No Color

# Function to display help information
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Repair Pacman package manager database and keyring issues"
    echo
    echo "Options:"
    echo "  -h, --help     Display this help message and exit"
    echo
    echo "This script will:"
    echo "  1. Remove sync databases"
    echo "  2. Remove GnuPG keyring"
    echo "  3. Remove pacman db lock"
    echo "  4. Initialize and populate pacman keyring"
    echo "  5. Synchronize and update packages"
    echo
    echo "Note: This script must be run with root privileges"
    exit 0
}

# Function to print error messages
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to print success messages
success_message() {
    echo -e "${GREEN}$1${NC}"
}

# Function to check if pacman db is locked
check_db_lock() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        echo -e "${RED}!!! Pacman database is locked.${NC}"
        return 1 # Return failure instead of exiting
    fi
    return 0 # Return success if no lock is found
}

# Function to remove pacman db lock
remove_db_lock() {
    echo -e "${LIGHT_BLUE}==>> Removing pacman db lock...${NC}"
    sudo rm -fv /var/lib/pacman/db.lck
}   

# Main repair function
repair_pacman() {
    echo -e "${YELLOW}Starting Pacman database and keyring repair...${NC}"

    # Remove db lock if it exists
    echo -e "${LIGHT_BLUE}==>> Checking for pacman db lock...${NC}"
    if ! check_db_lock; then
        remove_db_lock
    else
        echo -e "${GREEN}>> Pacman db lock not found.${NC}"
    fi

    # Remove sync databases
    echo -e "${LIGHT_BLUE}==>> Removing sync databases...${NC}"
    sudo rm -Rfv /var/lib/pacman/sync || error_exit "Failed to remove sync databases"

    # Remove gnupg directory
    echo -e "${LIGHT_BLUE}==>> Removing GnuPG keyring...${NC}"
    sudo rm -Rfv /etc/pacman.d/gnupg || error_exit "Failed to remove GnuPG directory"

    # Initialize pacman keyring
    echo -e "${LIGHT_BLUE}==>> Initializing pacman keyring...${NC}"
    sudo pacman-key --init || error_exit "Failed to initialize pacman keyring"

    # Populate pacman keyring
    echo -e "${LIGHT_BLUE}==>> Populating pacman keyring...${NC}"
    sudo pacman-key --populate || error_exit "Failed to populate pacman keyring"

    # Synchronize and update packages
    echo -e "${LIGHT_BLUE}==>> Synchronizing and updating packages...${NC}"
    sudo pacman -Syyuu --noconfirm || error_exit "Failed to update packages"

    success_message "Pacman repair completed successfully!"
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# Function to check root privileges
check_root_privileges() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root or with sudo"
    fi
}

# Function to confirm user action
confirm_action() {
    read -p "This will reset your Pacman database. Are you sure? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${RED}!! Operation cancelled.${NC} "
        exit 0
    fi
}

# Alchemist's den
main() {
    parse_arguments "$@"
    check_root_privileges
    confirm_action
    repair_pacman
}

# Abra-kadabra!
main "$@"
