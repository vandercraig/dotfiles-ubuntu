#!/bin/bash

# Development Environment Setup Script
# For Ubuntu WSL with Zsh, and Python development tools

set -e  # Exit on any error

# Ensure ~/.local/bin and ~/bin are in the PATH for this script
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

echo "🚀 Starting development environment setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running on Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    print_error "This script is designed for Ubuntu/Debian systems"
    exit 1
fi

# Install Nushell
print_status "Installing Nushell..."
if ! command -v nu &> /dev/null; then
    # Add Nushell apt repository and install
    curl -fsSL https://apt.fury.io/nushell/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg
    echo "deb https://apt.fury.io/nushell/ /" | sudo tee /etc/apt/sources.list.d/fury.list
    sudo apt update
    sudo apt install -y nushell
    if command -v nu &> /dev/null; then
        print_success "Nushell installed"
    else
        print_error "Nushell installation failed"
    fi
else
    print_warning "Nushell already installed"
fi

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install base packages
print_status "Installing base packages..."
sudo apt install -y \
    zsh \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    zip \
    tree \
    htop \
    jq \
    sqlite3 \
    neofetch \
    stow \
    bat \
    zsh-autosuggestions \
    zsh-syntax-highlighting

# Install WezTerm (modern terminal emulator), but not on WSL
print_status "Checking for WezTerm installation..."
if [ -z "$WSL_DISTRO_NAME" ]; then
    if ! command -v wezterm &> /dev/null; then
        print_status "Installing WezTerm (not on WSL)..."
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
        sudo apt update
        sudo apt install -y wezterm
        print_success "WezTerm installed."
    else
        print_warning "WezTerm already installed."
    fi
else
    print_warning "Skipping WezTerm installation on WSL."
fi

# Install Starship prompt
print_status "Installing Starship prompt..."
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    print_success "Starship installed"
else
    print_warning "Starship already installed"
fi

# Configure Starship with custom theme
print_status "Configuring Starship theme..."
if [ -f "starship_theme.toml" ]; then
    mkdir -p "$HOME/.config"
    cp starship_theme.toml "$HOME/.config/starship.toml"
    print_success "Custom Starship theme applied"
else
    print_warning "starship_theme.toml not found, using default Starship configuration"
fi

# Install uv (Python package manager)
print_status "Installing uv..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    print_success "uv installed"
    print_warning "You may need to restart your shell for uv to be in your PATH"
else
    print_warning "uv already installed"
fi

# Install Python via uv for better version management
print_status "Installing Python 3.12 via uv..."
if command -v uv &> /dev/null; then
    # Install Python 3.12 which is great for data engineering
    uv python install 3.12 || print_warning "Python 3.12 installation failed or already exists"
    print_success "Python 3.12 available via uv"
fi

# Install Node.js and npm (latest LTS)
print_status "Installing Node.js and npm..."
if ! command -v npm &> /dev/null; then
    # Install Node.js via NodeSource repository for latest LTS
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js and npm installed"
    node --version
    npm --version
else
    print_warning "Node.js and npm already installed"
    node --version
    npm --version
fi

# Install Docker (Engine, CLI, Compose)
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Remove any old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
    # Install dependencies
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # Update and install Docker packages
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    print_success "Docker and Docker Compose installed"
    # Add current user to docker group
    sudo usermod -aG docker $USER
    print_success "Added $USER to docker group (log out and back in for effect)"
else
    print_warning "Docker already installed"
fi

# Make zsh the default shell (optional)
print_status "Setting up default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    print_warning "Current shell is not zsh. To make zsh your default shell, run:"
    echo "chsh -s \$(which zsh)"
    echo "Then log out and back in."
else
    print_success "Zsh is already your default shell"
fi

# Install Just (command runner)
print_status "Installing Just (command runner)..."
if command -v uv &> /dev/null; then
    uv tool install just
    print_success "Just (command runner) installed via uv"
else
    print_warning "uv not available, skipping Just installation"
fi

# Install Claude Code
print_status "Installing Claude Code..."
if ! command -v claude-code &> /dev/null && command -v npm &> /dev/null; then
    # Configure npm to use local prefix to avoid sudo
    npm config set prefix ~/.local
    npm install -g @anthropic-ai/claude-code
    print_success "Claude Code installed locally"
elif ! command -v npm &> /dev/null; then
    print_warning "npm not available, skipping Claude Code installation"
else
    print_warning "Claude Code already installed"
fi

# Install Gemini CLI
print_status "Installing Gemini CLI..."
if ! command -v gemini &> /dev/null && command -v npm &> /dev/null; then
    npm install -g @google/gemini-cli
    print_success "Gemini CLI installed"
elif ! command -v npm &> /dev/null; then
    print_warning "npm not available, skipping Gemini CLI installation"
else
    print_warning "Gemini CLI already installed"
fi


# Install data engineering tools
print_status "Installing additional data engineering tools..."

# Install DuckDB CLI
if ! command -v duckdb &> /dev/null; then
    curl https://install.duckdb.org | sh
    print_success "DuckDB CLI installed"
else
    print_warning "DuckDB CLI already installed"
fi

# Install Python tools via uv
if command -v uv &> /dev/null; then
    print_status "Installing Python development tools via uv..."
    
    # Install ruff (Python linter/formatter)
    uv tool install ruff
    print_success "Ruff (Python linter/formatter) installed via uv"
    
    # Install pre-commit (Git hooks framework)
    uv tool install pre-commit
    print_success "pre-commit installed via uv"
    
    # Install pyright
    uv tool install pyright
    print_success "Pyright (Python type checker) installed via uv"
    
    # Install bandit
    uv tool install bandit
    print_success "Bandit (security linter) installed via uv"
    
    # Install datasette
    uv tool install datasette
    print_success "Datasette (instant web API for datasets) installed via uv"
    
    # Install litecli
    uv tool install litecli
    print_success "LiteCLI (enhanced SQLite CLI) installed via uv"
    
    # Install csvkit
    uv tool install csvkit
    print_success "CSVKit (CSV utilities) installed via uv"
    
    # Install rich-cli
    uv tool install rich-cli
    print_success "Rich-CLI (beautiful terminal output) installed via uv"
    
    # Install pytest
    uv tool install pytest
    print_success "pytest installed via uv"
else
    print_warning "uv not available, skipping Python tools installation"
fi

# Create backup of existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.zshrc.backup" ]; then
    print_status "Creating backup of existing .zshrc..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
    print_success "Backup created at ~/.zshrc.backup"
fi

# Ensure ~/bin is in PATH for Just and other local binaries
if [ ! -d "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
fi

# Add ~/bin to PATH in .zshrc if not already there
if [ -f "$HOME/.zshrc" ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
    print_success "Added ~/bin to PATH in .zshrc"
fi

# Create symbolic link for bat from batcat
print_status "Creating symbolic link for bat from batcat..."
if [ -f /usr/bin/batcat ]; then
    mkdir -p "$HOME/.local/bin"
    if [ ! -L "$HOME/.local/bin/bat" ]; then
        ln -s /usr/bin/batcat "$HOME/.local/bin/bat"
        print_success "Symbolic link for bat created"
    else
        print_warning "Symbolic link for bat already exists"
    fi
else
    print_warning "batcat not found, skipping symbolic link creation"
fi

# Log installed components
echo "📋 Installed components:" > INSTALLED_COMPONENTS.md
echo "- zsh" >> INSTALLED_COMPONENTS.md
echo "- zsh-autosuggestions plugin" >> INSTALLED_COMPONENTS.md
echo "- zsh-syntax-highlighting plugin" >> INSTALLED_COMPONENTS.md
echo "- Starship prompt (cross-shell)" >> INSTALLED_COMPONENTS.md
echo "- uv (Python package manager)" >> INSTALLED_COMPONENTS.md
echo "- Python 3.12 (via uv)" >> INSTALLED_COMPONENTS.md
echo "- Node.js (latest LTS)" >> INSTALLED_COMPONENTS.md
echo "- npm (comes with Node.js)" >> INSTALLED_COMPONENTS.md
echo "- Just (command runner)" >> INSTALLED_COMPONENTS.md
echo "- Claude Code (Anthropic CLI tool)" >> INSTALLED_COMPONENTS.md
echo "- Gemini CLI (Google's generative AI CLI)" >> INSTALLED_COMPONENTS.md
echo "- DuckDB CLI (OLAP database)" >> INSTALLED_COMPONENTS.md
echo "- Ruff (Python linter/formatter via uv)" >> INSTALLED_COMPONENTS.md
echo "- pre-commit (Git hooks framework via uv)" >> INSTALLED_COMPONENTS.md
echo "- Black (Python formatter via uv)" >> INSTALLED_COMPONENTS.md
echo "- Pyright (Python type checker via uv)" >> INSTALLED_COMPONENTS.md
echo "- Bandit (Python security linter via uv)" >> INSTALLED_COMPONENTS.md
echo "- Datasette (instant web API for datasets via uv)" >> INSTALLED_COMPONENTS.md
echo "- LiteCLI (enhanced SQLite CLI via uv)" >> INSTALLED_COMPONENTS.md
echo "- CSVKit (CSV utilities via uv)" >> INSTALLED_COMPONENTS.md
echo "- Rich-CLI (beautiful terminal output via uv)" >> INSTALLED_COMPONENTS.md
echo "- Build essentials and common tools" >> INSTALLED_COMPONENTS.md
echo "- Additional utilities: unzip, zip, tree, htop, jq, sqlite3" >> INSTALLED_COMPONENTS.md
echo "" >> INSTALLED_COMPONENTS.md
echo "## Data Engineering Focus:" >> INSTALLED_COMPONENTS.md
echo "- Fast Python package management with uv" >> INSTALLED_COMPONENTS.md
echo "- Modern Python tooling via uv tools (ruff, black, pyright, bandit, pre-commit)" >> INSTALLED_COMPONENTS.md
echo "- Data exploration tools (datasette, litecli, csvkit)" >> INSTALLED_COMPONENTS.md
echo "- Beautiful terminal output (rich-cli)" >> INSTALLED_COMPONENTS.md
echo "- DuckDB for analytics and data processing" >> INSTALLED_COMPONENTS.md
echo "- SQLite3 for lightweight database work" >> INSTALLED_COMPONENTS.md
echo "- jq for JSON processing in pipelines" >> INSTALLED_COMPONENTS.md
echo "- Git hooks with pre-commit for code quality" >> INSTALLED_COMPONENTS.md
echo "- Docker Engine, CLI, Compose" >> INSTALLED_COMPONENTS.md
echo "- Nushell (modern shell)" >> INSTALLED_COMPONENTS.md

print_success "Component list saved to INSTALLED_COMPONENTS.md"


print_success "🎉 Setup complete!"
echo
echo "Next steps:"
echo
echo "📌 Setting up Zsh as your default shell:"
echo "   If zsh is not your default shell, run the following commands:"
echo "   1. chsh -s \$(which zsh)"
echo "   2. Log out and log back in (or restart your terminal session)"
echo "   3. Verify with: echo \$SHELL (should show path to zsh)"
echo
echo "📌 Configuring your shell:"
echo "   1. Copy your .zshrc configuration to this directory if needed"
echo "   2. Restart your terminal or run: source ~/.zshrc"
echo "   3. Verify Starship is working - you should see a customized prompt"
echo
echo "📌 Setting up Nushell (optional modern shell):"
echo "   See nushell-setup.md for detailed Nushell configuration with Starship"
echo "   Quick setup:"
echo "   1. starship init nu | save --force ~/.cache/starship/init.nu"
echo "   2. Add Starship configuration to ~/.config/nushell/config.nu"
echo "   3. Run 'nu' to start Nushell"
echo
echo "📌 Additional customization:"
echo "   1. Run 'starship config' to customize your prompt further"
echo "   2. Install additional tools as needed"
echo "   3. Review INSTALLED_COMPONENTS.md for what was installed"
echo "   4. Configure Docker: run 'docker run hello-world' to test"