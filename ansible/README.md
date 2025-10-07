# Ansible Dotfiles Setup

This Ansible playbook automates the setup of your development environment based on the `env_setup.sh` and `install.sh` scripts.

## What It Does

### Package Installation
- Updates system packages
- Installs base utilities (git, curl, wget, build-essential, etc.)
- Installs development tools (zsh, neovim, ripgrep, fd, bat, etc.)
- Installs WezTerm terminal emulator (skipped on WSL)
- Installs Nushell
- Installs Starship prompt
- Installs uv (Python package manager)
- Installs Python 3.12 via uv
- Installs Node.js LTS
- Installs Docker and Docker Compose

### Python Development Tools (via uv)
- ruff
- pyright
- bandit
- pre-commit
- duckdb
- datasette
- litecli
- csvkit
- rich-cli
- just

### Symlinks & Configuration
- Creates symlink for `.zshrc` (backs up existing)
- Creates symlink for `nvim` config (backs up existing)
- Creates symlink for `wezterm.lua` config (backs up existing, skipped on WSL)
- Copies Starship theme to `~/.config/starship.toml`
- Creates `bat` symlink from `batcat`
- Creates `fd` symlink from `fdfind`
- Sets zsh as default shell

## Prerequisites

1. **Install Ansible** on your system:
   ```bash
   sudo apt update
   sudo apt install ansible -y
   ```

2. **Clone your dotfiles repository** if you haven't already:
   ```bash
   git clone <your-repo-url>
   cd dotfiles-ubuntu
   ```

## Usage

### Run the complete setup
```bash
cd ansible
ansible-playbook playbook.yml --ask-become-pass
```

### Run specific tasks with tags (coming soon)
You can add tags to the tasks if you want to run only certain parts:
```bash
# Example (after adding tags):
ansible-playbook playbook.yml --tags "packages" --ask-become-pass
ansible-playbook playbook.yml --tags "symlinks" --ask-become-pass
```

### Dry run (check mode)
See what would change without making any changes:
```bash
ansible-playbook playbook.yml --ask-become-pass --check
```

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts               # Inventory file (localhost)
├── playbook.yml            # Main playbook
├── roles/
│   └── dotfiles/
│       ├── tasks/
│       │   └── main.yml    # All tasks
│       └── handlers/
│           └── main.yml    # Handlers (e.g., reload shell)
└── README.md               # This file
```

## Post-Installation

After running the playbook:

1. **Log out and back in** for the docker group changes to take effect
2. **Restart your terminal** or run `source ~/.zshrc` to load the new shell configuration
3. **Test Docker**: `docker run hello-world`
4. **Verify installations**:
   ```bash
   zsh --version
   nvim --version
   starship --version
   uv --version
   node --version
   docker --version
   ```

## Customization

### Modify Package List
Edit `roles/dotfiles/tasks/main.yml` and modify the package lists in the relevant tasks.

### Add More Python Tools
Add tools to the `uv tool install` loop in `roles/dotfiles/tasks/main.yml`:
```yaml
- name: Install Python development tools via uv
  shell: "{{ user_home }}/.local/bin/uv tool install {{ item }}"
  loop:
    - ruff
    - your-new-tool
```

### Skip Certain Steps
Comment out or remove tasks you don't want to run.

## Troubleshooting

### Permission Errors
Make sure you run with `--ask-become-pass` so Ansible can use sudo when needed.

### uv or Docker Not in PATH
Log out and back in, or restart your terminal.

### Symlink Already Exists
The playbook backs up existing files before creating symlinks. Check for `.backup` files in your home directory.

### Docker Permission Denied
Log out and back in after the playbook runs to refresh your group membership.

## Comparison with Shell Scripts

This Ansible playbook replaces:
- `env_setup.sh` - Package installation and tool setup
- `install.sh` - Symlink creation

**Benefits of Ansible:**
- Idempotent (safe to run multiple times)
- Better error handling
- Structured and organized
- Easy to extend and maintain
- Can be run on remote machines
- Built-in backup functionality

## License

This configuration is provided as-is for personal and educational use.
