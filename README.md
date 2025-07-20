# Development Environment Setup

This repository contains scripts and configurations to quickly reproduce my Ubuntu WSL development environment focused on Python data engineering with a beautiful, modern terminal setup.

## What Gets Installed

### Core Shell Environment
- **Zsh** - Enhanced shell with better features than bash
- **Oh My Zsh** - Framework for managing Zsh configuration
- **Starship** - Fast, cross-shell prompt with custom DraculaPlus theme
- **zsh-autosuggestions** - Fish-like autosuggestions for Zsh
- **zsh-syntax-highlighting** - Real-time syntax highlighting

### Python Development Tools
- **uv** - Fast Python package installer and resolver
- **Python 3.12** - Latest Python version installed via uv
- **Ruff** - Fast Python linter and formatter (via uv)
- **Pyright** - Python type checker (via uv)
- **Bandit** - Security linter for Python (via uv)
- **pre-commit** - Git hooks framework (via uv)

### Data Engineering Tools
- **DuckDB** - High-performance analytical database
- **Datasette** - Instant web API for datasets (via uv)
- **LiteCLI** - Enhanced SQLite CLI with syntax highlighting (via uv)
- **CSVKit** - Suite of utilities for working with CSV files (via uv)
- **Rich-CLI** - Beautiful terminal output and formatting (via uv)

### Development Utilities
- **Just** - Command runner for automating project tasks
- **Claude Code** - Anthropic's AI-powered development assistant
- **Node.js (LTS)** - JavaScript runtime for tooling and utilities
- **npm** - Node package manager (comes with Node.js)
- **Build essentials** - Compiler tools for building packages
- **Additional utilities**: git, curl, wget, tree, htop, jq, sqlite3

## Quick Start

### 1. Install Nerd Fonts (for Windows Terminal)
Download and install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/) for proper icon display. Recommended fonts:
- **FiraCode Nerd Font** (recommended)
- **JetBrains Mono Nerd Font**
- **Hack Nerd Font**

After installation, configure Windows Terminal to use the font:
1. Open Windows Terminal Settings (Ctrl + Shift + ,)
2. Go to your WSL profile (Ubuntu) → Appearance
3. Set Font face to your chosen Nerd Font
4. Set Font size to 11 or 12

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
```bash
# Copy the Zsh configuration
cp .zshrc ~/.zshrc

# Restart your terminal or reload the configuration
source ~/.zshrc
```

The setup script will automatically:
- Install all development tools and dependencies
- Configure Starship with the custom DraculaPlus theme
- Set up Oh My Zsh with useful plugins
- Install Python tools via uv for better package management

## Repository Structure

```
.
├── env_setup.sh              # Main setup script (run in WSL)
├── .zshrc                    # Zsh configuration with Starship
├── starship_theme.toml       # Custom Starship theme (DraculaPlus)
├── terminal-theme.jsonc      # Windows Terminal color schemes
├── README.md                 # This file
├── INSTALLED_COMPONENTS.md   # List of installed components (auto-generated)
└── install-fonts-windows.*  # Legacy font scripts (use nerdfonts.com instead)
```

## Features

### Custom Starship Theme
- **DraculaPlus color scheme** with vibrant, developer-friendly colors
- **Username hidden** for cleaner look (shows only for root/SSH)
- **Input on new line** for better readability
- **Git integration** with branch and status information
- **Programming language detection** (Python, Node.js, Rust, Go, etc.)
- **Virtual environment support** for Python projects
- **Command duration** display for performance monitoring

### Python Development Focus
- **Modern tooling** via uv package manager for faster installs
- **Type checking** with Pyright instead of mypy
- **Code quality** with Ruff (linting + formatting in one tool)
- **Security scanning** with Bandit
- **Git hooks** with pre-commit for automated quality checks

### Data Engineering Ready
- **DuckDB** for high-performance analytics
- **CSV processing** with CSVKit utilities
- **Database exploration** with LiteCLI and Datasette
- **Beautiful output** with Rich-CLI for better data visualization

## Customization

### Changing Starship Theme Colors
The repository includes multiple color schemes in `terminal-theme.jsonc`:
- **DraculaPlus** (current)
- **OneStar** 
- **Lovelace**
- **CoolNight**

To switch themes, edit `starship_theme.toml` and change the `palette` value.

### Adding More Oh My Zsh Plugins
Edit the `plugins` array in `.zshrc`:
```bash
plugins=(
    git
    python
    pip
    docker
    zsh-autosuggestions
    zsh-syntax-highlighting
    z
    extract
    colored-man-pages
    # Add your new plugin here
)
```

### Adding More uv Tools
Edit `env_setup.sh` to add new Python tools:
```bash
if ! uv tool list | grep -q "tool-name"; then
    uv tool install tool-name
    print_success "Tool description installed via uv"
else
    print_warning "Tool already installed via uv"
fi
```

## Troubleshooting

### Font and Icon Issues
- **Missing icons**: Install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/)
- **Font not applied**: Restart Windows Terminal completely after font installation
- **Broken symbols**: Ensure Windows Terminal is using the Nerd Font in profile settings

### Shell and Plugin Issues
- **Zsh not default**: Run `chsh -s $(which zsh)` and restart terminal
- **Plugin errors**: Ensure setup script completed successfully
- **Starship not loading**: Check that `eval "$(starship init zsh)"` is in `.zshrc`

### Python and uv Issues
- **uv commands not found**: Restart terminal or run `source ~/.local/bin/env`
- **Tool installation fails**: Check internet connection and try `uv self update`
- **Permission errors**: Ensure you're not using sudo with uv commands

### WSL-Specific Issues
- **Slow startup**: Try `wsl --shutdown` and restart
- **Path issues**: Ensure `~/bin` is in your PATH (automatically added by script)

## Updates and Maintenance

### Update Components
```bash
# Update Oh My Zsh and plugins
omz update

# Update Starship
curl -sS https://starship.rs/install.sh | sh

# Update uv and Python tools
uv self update
uv tool upgrade --all

# Update Node.js tools
npm update -g
```

### Backup Your Configuration
```bash
# Backup important configs
cp ~/.zshrc ~/backup-zshrc
cp ~/.config/starship.toml ~/backup-starship.toml
```

## What Makes This Setup Special

1. **Modern Tools**: Uses uv instead of pip for faster Python package management
2. **Beautiful Terminal**: Starship with custom themes and Nerd Font icons
3. **Data Engineering Focus**: Pre-configured tools for data analysis and processing
4. **Cross-Shell Compatibility**: Starship works in any shell (zsh, bash, fish, etc.)
5. **Idempotent Setup**: Script can be run multiple times safely
6. **No Root Required**: Everything installs to user directories where possible

## Contributing

When adding new tools or configurations:

1. Update `env_setup.sh` with installation steps
2. Update `.zshrc` if shell configuration changes are needed
3. Test the setup on a clean environment
4. Update this README with new features
5. Update `INSTALLED_COMPONENTS.md` if the script generates it

## License

This dotfiles configuration is provided as-is for personal and educational use.