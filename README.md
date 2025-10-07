# Development Environment Setup

Automated setup for Ubuntu development environment using **Ansible** (packages) and **GNU Stow** (config symlinks).

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
git clone https://github.com/vandercraig/dotfiles-ubuntu.git
cd dotfiles-ubuntu

# Install Ansible if not already installed
sudo apt update && sudo apt install -y ansible

# Run the Ansible playbook to install packages
cd ansible
ansible-playbook playbook.yml --ask-become-pass

# Return to root and link config files with Stow
cd ..
./stow.sh install
```

The Ansible playbook will:

- Install all packages (system tools, dev tools, neovim, etc.)
- Install WezTerm (skipped on WSL)
- Install GNU Stow for config management
- Configure your shell environment
- Set zsh as default shell

See `ansible/README.md` for more details about package installation.

### 3. Manage Dotfiles

```bash
# Install/link all configs
./stow.sh install

# Uninstall/unlink all configs
./stow.sh uninstall

# Re-link after making changes
./stow.sh restow
```

**Active Symlinks:**

- `~/.zshrc` → `zsh/.zshrc`
- `~/.config/nvim` → `nvim/.config/nvim`
- `~/.config/nushell` → `nushell/.config/nushell`
- `~/.config/wezterm/wezterm.lua` → `wezterm/.config/wezterm/wezterm.lua`
- `~/.config/starship.toml` → `starship/.config/starship.toml`

### 4. Post-Installation

- **Log out and back in** for shell/Docker group changes
- **Restart terminal** or run `source ~/.zshrc`
- WezTerm auto-skipped on WSL systems

### 5. Code Quality (Optional)

If you modify configs, pre-commit hooks maintain code quality:

```bash
# Install direnv (handles pre-commit auto-install)
sudo apt install direnv
eval "$(direnv hook zsh)"  # Add to ~/.zshrc
direnv allow

# Or install pre-commit manually
pre-commit install
pre-commit run --all-files  # Run checks
```

## Structure

```bash
ansible/               # Package installation
  playbook.yml         # Main automation
  roles/dotfiles/tasks/main.yml

zsh/.zshrc            # → ~/.zshrc
nvim/.config/nvim/    # → ~/.config/nvim
wezterm/.config/      # → ~/.config/wezterm
starship/.config/     # → ~/.config/starship.toml
nushell/.config/      # → ~/.config/nushell

stow.sh               # Symlink helper
```

## Customization

**Config files are symlinked** - edit directly in the repo and changes apply immediately:

```bash
# Example: Edit WezTerm config
vim wezterm/.config/wezterm/wezterm.lua

# Changes are live, commit to track
git add wezterm/
git commit -m "Update wezterm theme"
```

**Add Python tools:** Edit `ansible/roles/dotfiles/tasks/main.yml`:

```yaml
loop:
  - ruff
  - pyright
  - your-tool  # Add here
```

## Troubleshooting

**Stow conflicts:** Backup existing configs before stowing

```bash
mkdir -p ~/dotfiles-backups && mv ~/.zshrc ~/.config/nvim ~/dotfiles-backups/
./stow.sh install
```

**Tools not found:** Restart terminal or add to `~/.zshrc`: `export PATH="$HOME/.local/bin:$PATH"`

**Missing icons:** Install a Nerd Font and configure in `wezterm.lua`

**Zsh not default:** Run `chsh -s $(which zsh)` and restart terminal

## Updates

```bash
# System packages
sudo apt update && apt upgrade -y

# Starship
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Python tools
uv self update && uv tool upgrade --all

# Node packages
npm update -g
```

## License

This configuration is provided as-is for personal and educational use.
