#!/bin/bash

# ------------------------------------------------------------------------------
# Dotfiles Installation Script
# ------------------------------------------------------------------------------
# This script creates symlinks for dotfiles configurations, backing up existing
# files/directories if they exist.
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
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create backup and symlink
create_symlink() {
    local source_path="$1"
    local target_path="$2"
    local backup_path="${target_path}.backup"

    print_status "Processing: $target_path"

    # Check if target already exists
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        # Check if it's already a symlink to our source
        if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
            print_success "Symlink already exists and points to correct location: $target_path"
            return 0
        fi

        # Create backup
        print_warning "Existing file/directory found. Creating backup: $backup_path"

        # Remove existing backup if it exists
        if [ -e "$backup_path" ]; then
            rm -rf "$backup_path"
        fi

        # Move existing file/directory to backup
        mv "$target_path" "$backup_path"
        print_success "Backup created: $backup_path"
    fi

    # Create the symlink
    ln -s "$source_path" "$target_path"
    print_success "Symlink created: $target_path -> $source_path"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Starting dotfiles installation from: $SCRIPT_DIR"
echo

# Create symlinks
print_status "Creating symlinks..."

# Symlink .zshrc
create_symlink "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

# Symlink nvim configuration
create_symlink "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

echo
print_success "Dotfiles installation completed!"
print_status "Don't forget to restart your shell or run 'source ~/.zshrc' to apply changes."

# Check if .zshrc.local exists and provide guidance
if [ ! -f "$HOME/.zshrc.local" ]; then
    echo
    print_status "Optional: Create ~/.zshrc.local for machine-specific configuration"
    print_status "This file will be automatically sourced by your .zshrc if it exists"
fi
