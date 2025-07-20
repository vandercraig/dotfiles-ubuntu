# Development Environment Setup

This repository contains scripts and configurations to set up a development environment on Ubuntu WSL, with a focus on Python data engineering.

## What Gets Installed

### Core Shell Environment
- **Zsh**: A powerful, modern shell.
- **Oh My Zsh**: A framework for managing Zsh configuration.
- **Nushell**: A modern, cross-platform shell.
- **Starship**: A fast, cross-shell prompt.
- **zsh-autosuggestions**: Fish-like autosuggestions for Zsh.
- **zsh-syntax-highlighting**: Real-time syntax highlighting for Zsh.

### Python Development
- **uv**: A fast Python package installer and resolver.
- **Python 3.12**: Installed via `uv`.
- **Ruff**: A fast Python linter and formatter.
- **Pyright**: A static type checker for Python.
- **Bandit**: A security linter for Python.
- **pre-commit**: A framework for managing Git pre-commit hooks.

### Data Engineering Tools
- **DuckDB**: An in-process SQL OLAP database management system.
- **Datasette**: A tool for exploring and publishing data.
- **LiteCLI**: An enhanced CLI for SQLite.
- **CSVKit**: A suite of command-line tools for working with CSV.
- **Rich-CLI**: A tool for rich text and beautiful formatting in the terminal.

### Development Utilities
- **Just**: A command runner.
- **Claude Code**: Anthropic's CLI tool.
- **Node.js (LTS)**: A JavaScript runtime.
- **Docker**: A platform for developing, shipping, and running applications in containers.
- **Build essentials**: Compiler tools for building from source.
- **Common utilities**: `git`, `curl`, `wget`, `tree`, `htop`, `jq`, `sqlite3`.

## Quick Start

### 1. Install a Nerd Font
For icons to render correctly in the terminal, download and install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/).
Recommended fonts: FiraCode Nerd Font, JetBrains Mono Nerd Font.

After installation, configure your terminal (e.g., Windows Terminal) to use the chosen Nerd Font in your profile settings.

### 2. Clone and Run Setup
```bash
# Clone this repository
git clone <your-repo-url>
cd <repo-name>

# Make the setup script executable and run it
chmod +x env_setup.sh
./env_setup.sh
```

### 3. Apply Shell Configuration

#### For Zsh
```bash
# Copy the Zsh configuration
cp .zshrc ~/.zshrc

# Restart your terminal or reload the configuration
source ~/.zshrc
```

#### For Nushell
```bash
# Run the Nushell configuration script
nu configure_nushell.nu
```

The setup script installs all tools and dependencies. The shell configurations link everything together.

## Repository Structure

```
.
├── env_setup.sh              # Main setup script
├── configure_nushell.nu      # Configuration script for Nushell
├── .zshrc                    # Zsh configuration
├── starship/starship_theme.toml # Custom Starship theme
├── terminal-theme.jsonc      # Windows Terminal color schemes
├── README.md                 # This file
└── INSTALLED_COMPONENTS.md   # Auto-generated list of installed components
```

## Features

### Custom Starship Theme
- Based on the DraculaPlus color scheme.
- Hides the username for a cleaner look (shows only for root/SSH).
- Displays Git branch and status.
- Detects and shows the version of programming languages (Python, Node.js, etc.).
- Shows Python virtual environment status.

### Python Development
- Fast package management with `uv`.
- Code quality enforced with `ruff` (linting and formatting), `pyright` (type checking), and `bandit` (security).
- Git hooks managed with `pre-commit` for automated quality checks.

### Data Engineering Tools
- **DuckDB** for high-performance analytics.
- **CSVKit** for CSV processing.
- **LiteCLI** and **Datasette** for database exploration.
- **Rich-CLI** for better data visualization in the terminal.

## Customization

### Changing Starship Theme
The repository includes multiple color schemes in `terminal-theme.jsonc`. To switch themes, edit `starship/starship_theme.toml` and change the `palette` value.

### Adding Oh My Zsh Plugins
Edit the `plugins` array in `.zshrc`:
```zsh
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    # Add new plugins here
)
```

### Adding `uv` Tools
Edit `env_setup.sh` to add new Python tools installed via `uv`:
```bash
# In env_setup.sh
if ! uv tool list | grep -q "tool-name"; then
    uv tool install tool-name
    print_success "Tool description installed via uv"
else
    print_warning "Tool already installed via uv"
fi
```

## Troubleshooting

### Font and Icon Issues
- **Missing icons**: Ensure a Nerd Font is installed and configured in your terminal settings.
- **Broken symbols**: Restart your terminal after setting the font.

### Shell Issues
- **Zsh not default**: Run `chsh -s $(which zsh)` and restart the terminal.
- **Starship not loading**: Check that `eval "$(starship init zsh)"` is in `.zshrc`.

### `uv` Issues
- **`uv` command not found**: Restart your terminal or run `source ~/.bashrc` (or `~/.zshrc`). The installer adds it to the path.
- **Permission errors**: Do not use `sudo` with `uv` commands.

## Maintenance

### Update Components
```bash
# Update Oh My Zsh and plugins
omz update

# Update Starship
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Update uv and all installed tools
uv self update
uv tool upgrade --all

# Update Node.js global packages
npm update -g
```

### Backup Configuration
```bash
# Backup important configs
cp ~/.zshrc ~/zshrc.backup
cp ~/.config/starship.toml ~/starship.toml.backup
cp -r ~/.config/nushell ~/nushell.backup
```

## License

This configuration is provided as-is for personal and educational use.