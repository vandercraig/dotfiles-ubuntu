#!/bin/bash

# Development Environment Setup Script
# For Ubuntu WSL with Zsh, Oh My Zsh, and Python development tools

set -e  # Exit on any error

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
    bat

# Install Oh My Zsh
print_status "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
else
    print_warning "Oh My Zsh already installed"
fi

# Set ZSH_CUSTOM path
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Install zsh-autosuggestions plugin
print_status "Installing zsh-autosuggestions plugin..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions installed"
else
    print_warning "zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting plugin
print_status "Installing zsh-syntax-highlighting plugin..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed"
else
    print_warning "zsh-syntax-highlighting already installed"
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
    
    # Source the uv environment to make it available immediately
    if [ -f "$HOME/.local/bin/env" ]; then
        source "$HOME/.local/bin/env"
    fi
    
    print_success "uv installed"
    print_warning "You may need to restart your shell or run 'source ~/.bashrc' to use uv"
else
    print_warning "uv already installed"
fi

# Configure uv shell completions
print_status "Configuring uv shell completions..."
# Try to make uv available if it's not in current PATH
if ! command -v uv &> /dev/null && [ -f "$HOME/.local/bin/env" ]; then
    source "$HOME/.local/bin/env"
fi

if command -v uv &> /dev/null; then
    # Create completions directory if it doesn't exist
    mkdir -p "$HOME/.oh-my-zsh/completions"
    
    # Generate and save uv completions
    if uv generate-shell-completion zsh > "$HOME/.oh-my-zsh/completions/_uv" 2>/dev/null; then
        print_success "uv shell completions configured"
    else
        print_warning "Failed to generate uv completions, but continuing setup"
    fi
    
    # Add completions directory to fpath in .zshrc if not already there
    if [ -f "$HOME/.zshrc" ] && ! grep -q 'fpath=($HOME/.oh-my-zsh/completions $fpath)' "$HOME/.zshrc"; then
        echo 'fpath=($HOME/.oh-my-zsh/completions $fpath)' >> "$HOME/.zshrc"
        print_success "Added uv completions to fpath"
    fi
else
    print_warning "uv not available, skipping completions setup"
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
if ! command -v node &> /dev/null || [ "$(node -v | cut -d'.' -f1 | cut -d'v' -f2)" -lt 18 ]; then
    # Install Node.js via NodeSource repository for latest LTS
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js and npm installed"
    node --version
    npm --version
else
    print_warning "Node.js already installed"
    node --version
    npm --version
    
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
if ! command -v just &> /dev/null && [ ! -f "$HOME/bin/just" ]; then
    mkdir -p ~/bin
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin
    print_success "Just installed to ~/bin"
    print_warning "Make sure ~/bin is in your PATH (will be added to .zshrc)"
else
    print_warning "Just already installed"
fi

# Install Claude Code
print_status "Installing Claude Code..."
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/cli/install.sh | sh
    print_success "Claude Code installed"
else
    print_warning "Claude Code already installed"
fi

# # Install Gemini CLI
# print_status "Installing Gemini CLI..."
# if ! command -v gemini &> /dev/null && command -v npm &> /dev/null; then
#     npm install -g @google/gemini-cli
#     print_success "Gemini CLI installed"
# elif ! command -v npm &> /dev/null; then
#     print_warning "npm not available, skipping Gemini CLI installation"
# else
#     print_warning "Gemini CLI already installed"
# fi


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
    if ! uv tool list | grep -q "ruff"; then
        uv tool install ruff
        print_success "Ruff (Python linter/formatter) installed via uv"
    else
        print_warning "Ruff already installed via uv"
    fi
    
    # Install pre-commit (Git hooks framework)
    if ! uv tool list | grep -q "pre-commit"; then
        uv tool install pre-commit
        print_success "pre-commit installed via uv"
    else
        print_warning "pre-commit already installed via uv"
    fi
       
    if ! uv tool list | grep -q "pyright"; then
        uv tool install pyright
        print_success "Pyright (Python type checker) installed via uv"
    else
        print_warning "Pyright already installed via uv"
    fi
    
    if ! uv tool list | grep -q "bandit"; then
        uv tool install bandit
        print_success "Bandit (security linter) installed via uv"
    else
        print_warning "Bandit already installed via uv"
    fi
    
    # Install data engineering CLI tools
    if ! uv tool list | grep -q "datasette"; then
        uv tool install datasette
        print_success "Datasette (instant web API for datasets) installed via uv"
    else
        print_warning "Datasette already installed via uv"
    fi
    
    if ! uv tool list | grep -q "litecli"; then
        uv tool install litecli
        print_success "LiteCLI (enhanced SQLite CLI) installed via uv"
    else
        print_warning "LiteCLI already installed via uv"
    fi
    
    if ! uv tool list | grep -q "csvkit"; then
        uv tool install csvkit
        print_success "CSVKit (CSV utilities) installed via uv"
    else
        print_warning "CSVKit already installed via uv"
    fi
    
    if ! uv tool list | grep -q "rich-cli"; then
        uv tool install rich-cli
        print_success "Rich-CLI (beautiful terminal output) installed via uv"
    else
        print_warning "Rich-CLI already installed via uv"
    fi

    if ! uv tool list | grep -q "pytest"; then
        uv tool install pytest
        print_success "pytest installed via uv"
    else
        print_warning "pytest already installed via uv"
    fi    
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
echo "- Oh My Zsh" >> INSTALLED_COMPONENTS.md
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
echo "1. Copy your .zshrc configuration to this directory"
echo "2. Restart your terminal or run: source ~/.zshrc"
echo "3. Run 'starship config' to customize your prompt"
echo "4. Install additional tools as needed (see additional-tools.md)"