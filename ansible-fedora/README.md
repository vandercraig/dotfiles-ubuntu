# Ansible Fedora Setup

This Ansible playbook automates the setup of your development environment on **Fedora**.

## What It Does

### Package Installation

- Updates system packages
- Ensure base utilities are installed (git, curl, wget, development-tools, etc.)
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

### Configuration

- Sets zsh as default shell
- **Note**: Fedora packages `bat` and `fd` with correct names - no symlinks needed!

## Key Differences from Ubuntu Version

- Uses `dnf` instead of `apt`
- Uses `@development-tools` group instead of `build-essential`
- WezTerm installed from Copr repository
- Docker repo uses Fedora-specific URL
- No need for `bat`/`fd` symlinks (Fedora uses correct names)
- Uses `.repo` files for third-party repositories

## Prerequisites

1. **Install Ansible** on your Fedora system:

   ```bash
   sudo dnf install ansible -y
   ```

2. **Clone your dotfiles repository** if you haven't already:

   ```bash
   git clone <your-repo-url>
   cd dotfiles-ubuntu  # (consider renaming to dotfiles)
   ```

## Usage

### Run the complete setup

```bash
cd ansible-fedora
ansible-playbook playbook.yml --ask-become-pass
```

### Run specific tasks with tags

```bash
# Examples:
ansible-playbook playbook.yml --tags "base" --ask-become-pass
ansible-playbook playbook.yml --skip-tags "personal" --ask-become-pass
```

### Dry run (check mode)

See what would change without making any changes:

```bash
ansible-playbook playbook.yml --ask-become-pass --check
```

## Directory Structure

```bash
ansible-fedora/
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts               # Inventory file (localhost)
├── playbook.yml            # Main playbook
├── roles/
│   ├── dotfiles/
│   │   ├── tasks/
│   │   │   └── main.yml    # All tasks
│   │   └── handlers/
│   │       └── main.yml    # Handlers (e.g., reload shell)
│   └── personal/
│       ├── tasks/
│       │   └── main.yml    # Personal tools (Dropbox, Tailscale)
│       └── handlers/
│           └── main.yml    # Personal handlers
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
   bat --version     # Note: Just 'bat', not 'batcat'!
   fd --version      # Note: Just 'fd', not 'fdfind'!
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

### Copr Repository Fails

If WezTerm Copr fails, you can manually enable it:

```bash
sudo dnf copr enable wezfurlong/wezterm
sudo dnf install wezterm
```

### uv or Docker Not in PATH

Log out and back in, or restart your terminal.

### Docker Permission Denied

Log out and back in after the playbook runs to refresh your group membership.

### SELinux Issues

If you encounter SELinux denials, check:

```bash
sudo ausearch -m avc -ts recent
```
