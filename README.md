# Development Environment Setup

This repository contains scripts and configurations to set up a development environment on Ubuntu, with a focus on Python data engineering.

## What Gets Installed

### Core Components
- **WezTerm**: A powerful, GPU-accelerated terminal emulator (installed on non-WSL systems).
- **Zsh**: A modern shell with powerful features.
- **Nushell**: A modern, cross-platform shell.
- **Starship**: A fast, cross-shell prompt.
- **zsh-autosuggestions & zsh-syntax-highlighting**: Essential plugins for an enhanced Zsh experience.

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
- **Gemini CLI**: Google's generative AI CLI.
- **Node.js (LTS)**: A JavaScript runtime.
- **Docker**: A platform for developing, shipping, and running applications in containers.
- **Build essentials**: Compiler tools for building from source.
- **Common utilities**: `git`, `curl`, `wget`, `tree`, `htop`, `jq`, `sqlite3`.

## Quick Start

### 1. Install a Nerd Font
For icons to render correctly in the terminal, download and install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/).
Recommended fonts: FiraCode Nerd Font, JetBrains Mono Nerd Font.

After installation, configure your terminal to use the chosen Nerd Font.

### 2. Clone and Run Setup
```bash
# Clone this repository
git clone <your-repo-url>
cd <repo-name>

# Make the setup script executable and run it
chmod +x env_setup.sh
./env_setup.sh
```

### 3. Apply Shell & Terminal Configuration

#### For Zsh
```bash
# Copy the Zsh configuration
cp .zshrc ~/.zshrc

# Restart your terminal or reload the configuration
source ~/.zshrc
```

#### For WezTerm
```bash
# Create the config directory if it doesn't exist
mkdir -p ~/.config/wezterm

# Copy the WezTerm configuration
cp wezterm.lua ~/.config/wezterm/wezterm.lua
```

#### For Nushell
See `nushell-setup.md` for instructions on configuring Nushell with Starship.

## Repository Structure

```
.
├── env_setup.sh              # Main setup script
├── .zshrc                    # Zsh configuration
├── wezterm.lua               # WezTerm terminal configuration
├── nushell-setup.md          # Nushell setup guide
├── starship/starship_theme.toml # Custom Starship theme
├── terminal-theme.jsonc      # Color schemes for other terminals (e.g., Windows Terminal)
├── README.md                 # This file
└── INSTALLED_COMPONENTS.md   # Auto-generated list of installed components
```

## Customization

### WezTerm Personalization
The `wezterm.lua` configuration is parameterized for easy customization. Open the file and edit the `user_params` table at the top to change your theme, background image, font, and more.

**Example:**
```lua
-- In wezterm.lua
local user_params = {
  color_scheme = 'kanagawabones', -- or 'tokyonight'
  background_image_path = '/path/to/your/image.png',
  font = 'FiraCode Nerd Font',
  font_size = 12.0,
  background_tint_opacity = 0.85,
}
```

### Adding `uv` Tools
Edit `env_setup.sh` to add new Python tools installed via `uv`. `uv` handles cases where the tool is already installed.

**Example:**
```bash
# In env_setup.sh
uv tool install <tool-name>
print_success "<Tool description> installed via uv"
```

## Troubleshooting

### Font and Icon Issues
- **Missing icons**: Ensure a Nerd Font is installed and configured in your terminal (e.g., in `wezterm.lua`).
- **Broken symbols**: Restart your terminal after setting the font.

### Shell Issues
- **Zsh not default**: Run `chsh -s $(which zsh)` and restart the terminal.
- **Starship not loading**: Check that `eval "$(starship init zsh)"` is at the end of your `.zshrc`.

### `uv` Issues
- **`uv` command not found**: Restart your terminal or run `source ~/.zshrc`. The installer adds it to your shell's PATH.
- **Permission errors**: Do not use `sudo` with `uv` commands.

## Maintenance

### Update Components
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

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
cp ~/.config/wezterm/wezterm.lua ~/wezterm.lua.backup
cp -r ~/.config/nushell ~/nushell.backup
```

## License

This configuration is provided as-is for personal and educational use.
