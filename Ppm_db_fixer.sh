#!/usr/bin/env bash
#Qnk6IE1hZGUyRmxleA==

# Script to repair Pacman package manager database and keyring issues
# Useful after problematic mirror updates or database corruption

set -euo pipefail
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
        return 1
    fi
    return 0
}

# Function to remove pacman db lock
remove_db_lock() {
    echo -e "${LIGHT_BLUE}==>> Removing pacman db lock...${NC}"
    if ! sudo rm -fv /var/lib/pacman/db.lck; then
        error_exit "Failed to remove pacman db lock"
    fi
}

# Function to verify pacman installation
verify_pacman_installation() {
    if ! command -v pacman &> /dev/null; then
        error_exit "Pacman is not installed or not in PATH"
    fi
}

# Main repair function
repair_pacman() {
    echo -e "${YELLOW}==>> Starting Pacman database and keyring repair...${NC}"
    
    # Verify pacman is installed
    verify_pacman_installation

    # Remove db lock if it exists
    echo -e "${LIGHT_BLUE}==>> Checking for pacman db lock...${NC}"
    if ! check_db_lock; then
        remove_db_lock
    else
        echo -e "${GREEN}>> Pacman db lock not found.${NC}"
    fi

    # Remove sync databases
    echo -e "${LIGHT_BLUE}==>> Backing up and removing sync databases...${NC}"
    if [[ -d /var/lib/pacman/sync ]]; then
        local backup_dir="/var/lib/pacman/sync_backup_$(date +%Y%m%d_%H%M%S)"
        sudo mkdir -p "$backup_dir"
        sudo mv /var/lib/pacman/sync/* "$backup_dir/" || error_exit "Failed to backup sync databases"
    fi

    # Remove gnupg directory
    echo -e "${LIGHT_BLUE}==>> Backing up and removing GnuPG keyring...${NC}"
    if [[ -d /etc/pacman.d/gnupg ]]; then
        local gnupg_backup="/etc/pacman.d/gnupg_backup_$(date +%Y%m%d_%H%M%S)"
        sudo mv /etc/pacman.d/gnupg "$gnupg_backup" || error_exit "Failed to backup GnuPG directory"
    fi

    # Initialize pacman keyring
    echo -e "${LIGHT_BLUE}==>> Initializing pacman keyring...${NC}"
    sudo pacman-key --init || error_exit "Failed to initialize pacman keyring"

    # Populate pacman keyring
    echo -e "${LIGHT_BLUE}==>> Populating pacman keyring...${NC}"
    local retry_count=3
    for ((i=1; i<=retry_count; i++)); do
        if sudo pacman-key --populate; then
            break
        elif [[ $i -eq $retry_count ]]; then
            error_exit "Failed to populate pacman keyring after $retry_count attempts"
        else
            echo -e "${YELLOW}>> Retrying pacman-key populate (attempt $i of $retry_count)...${NC}"
            sleep 2
        fi
    done

    # Synchronize and update packages
    echo -e "${LIGHT_BLUE}==>> Synchronizing and updating packages...${NC}"
    if ! sudo pacman -Syyuu --noconfirm; then
        error_exit "Failed to update packages. Please check your internet connection and try again."
    fi

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
