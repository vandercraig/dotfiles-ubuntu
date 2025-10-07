#!/bin/bash

# ------------------------------------------------------------------------------
# Dotfiles Stow Manager
# ------------------------------------------------------------------------------
# This script manages dotfile symlinks using GNU Stow.
# Usage: ./stow.sh [install|uninstall|restow]
# ------------------------------------------------------------------------------

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of stow packages to manage
PACKAGES=(
    "zsh"
    "nvim"
    "starship"
    "nushell"
)

# Add wezterm only if not on WSL
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    PACKAGES+=("wezterm")
fi

# Function to stow packages
stow_packages() {
    print_status "Installing dotfiles via stow..."
    cd "$SCRIPT_DIR"

    for package in "${PACKAGES[@]}"; do
        print_status "Stowing $package..."
        if stow -v -t "$HOME" "$package" 2>&1 | grep -q "LINK:"; then
            print_success "$package configured"
        else
            print_warning "$package already configured or no changes needed"
        fi
    done

    print_success "All dotfiles installed!"
}

# Function to unstow packages
unstow_packages() {
    print_status "Removing dotfiles symlinks..."
    cd "$SCRIPT_DIR"

    for package in "${PACKAGES[@]}"; do
        print_status "Unstowing $package..."
        stow -D -t "$HOME" "$package" 2>/dev/null || print_warning "$package not stowed"
    done

    print_success "All dotfiles removed!"
}

# Function to restow packages (useful after changes)
restow_packages() {
    print_status "Re-stowing dotfiles..."
    cd "$SCRIPT_DIR"

    for package in "${PACKAGES[@]}"; do
        print_status "Re-stowing $package..."
        stow -R -t "$HOME" "$package"
    done

    print_success "All dotfiles re-stowed!"
}

# Main script logic
case "${1:-install}" in
    install)
        stow_packages
        ;;
    uninstall)
        unstow_packages
        ;;
    restow)
        restow_packages
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Usage: $0 [install|uninstall|restow]"
        echo ""
        echo "Commands:"
        echo "  install   - Create symlinks for all dotfiles (default)"
        echo "  uninstall - Remove all dotfile symlinks"
        echo "  restow    - Re-create symlinks (useful after updates)"
        exit 1
        ;;
esac
