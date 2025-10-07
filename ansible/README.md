# Ansible Dotfiles Setup

This Ansible playbook automates the setup of your development environment.

## What It Does

### Package Installation

- Updates system packages
- Ensure base utilities are installed (git, curl, wget, build-essential, etc.)
- Installs development tools (zsh, neovim, ripgrep, fd, bat, etc.)
- Agentic programming CLIs (claude, gemini)
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
- datasette
- litecli
- csvkit
- rich-cli
- just

### Symlinks & Configuration

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

### Run specific tasks with tags

```bash
# Examples:
ansible-playbook playbook.yml --tags "packages" --ask-become-pass
ansible-playbook playbook.yml --tags "symlinks" --ask-become-pass
```

### Dry run (check mode)

See what would change without making any changes:

```bash
ansible-playbook playbook.yml --ask-become-pass --check
```

## Directory Structure

```bash
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

## Troubleshooting

### Permission Errors

Make sure you run with `--ask-become-pass` so Ansible can use sudo when needed.

### uv or Docker Not in PATH

Log out and back in, or restart your terminal.

### Symlink Already Exists

The playbook backs up existing files before creating symlinks. Check for `.backup` files in your home directory.

### Docker Permission Denied

Log out and back in after the playbook runs to refresh your group membership.
