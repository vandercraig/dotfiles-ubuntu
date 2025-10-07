# GitHub Copilot Instructions

## Project Overview

This is an Ubuntu development environment setup using a two-phase approach:
1. **Ansible** - Package installation and system configuration
2. **GNU Stow** - Dotfiles symlink management

## Architecture Principles

- **Separation of concerns**: Ansible handles packages, Stow handles config files
- **Stow must run AFTER Ansible**: Packages (including `stow` itself) must be installed before symlinking configs
- **Idempotency**: All Ansible tasks check state before making changes
- **Cross-platform awareness**: Detect WSL and skip GUI applications (WezTerm) accordingly

## Key Technical Details

### Stow Configuration
- All Stow commands use `-t $HOME` flag (required when not running from parent of target)
- Package array: `zsh`, `nvim`, `starship`, `nushell`, `wezterm` (conditional on WSL)
- Directory structure: `<package>/.config/<app>/` → `~/.config/<app>/`
- Symlinks use relative paths for portability

### Ansible Patterns
```yaml
# WSL Detection
- name: Check if running on WSL
  shell: grep -qi microsoft /proc/version
  register: is_wsl
  failed_when: false
  changed_when: false

# Conditional installation based on WSL
when: is_wsl.rc != 0  # Install only when NOT on WSL

# Version checking with proper empty string handling
- name: Check current Neovim version
  shell: nvim --version 2>/dev/null | head -n1 | grep -oP 'v\K[0-9]+\.[0-9]+' || echo ""
  register: nvim_version_check
  changed_when: false
  failed_when: false

- name: Set Neovim version fact
  set_fact:
    nvim_version: "{{ nvim_version_check.stdout if nvim_version_check.stdout != '' else '0.0' }}"
```

### Ubuntu Package Quirks
- `bat` → `batcat` (requires symlink: `ln -s /usr/bin/batcat ~/.local/bin/bat`)
- `fd` → `fdfind` (requires symlink: `ln -s /usr/bin/fdfind ~/.local/bin/fd`)
- Always create these symlinks after installing packages

### Tool-Specific Notes

**Neovim**:
- Requires version 0.11+ for NvChad compatibility
- Installed via AppImage from: `https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage`
- Make executable and symlink to `~/.local/bin/nvim`

**WezTerm**:
- Skip on WSL (GUI app)
- Install via apt repository with key verification

**Python Tools (uv)**:
- Install via standalone installer: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Use `uv tool install <package>` for global Python tools
- Never use `sudo` with `uv` commands

## Code Style Preferences

### Shell Scripts
- Use `#!/usr/bin/env bash` for portability
- Include explicit error messages with context
- Use functions for reusable logic
- Check prerequisites before execution

### Ansible Tasks
- Always include `name:` field with clear descriptions
- Use `register:` for command outputs that need checking
- Set `changed_when: false` for read-only operations
- Include `failed_when: false` for optional checks
- Group related tasks with comments

### Documentation
- Keep README concise ("pithy")
- Use code blocks with language hints
- Show examples inline, not separate files
- Include exit conditions in troubleshooting

## Common Patterns

### Adding New Stow Package
1. Create directory: `<package>/.config/<app>/`
2. Move configs into the directory
3. Add package name to `PACKAGES` array in `stow.sh`
4. Test with `./stow.sh restow`

### Adding New Python Tool
Edit `ansible/roles/dotfiles/tasks/main.yml`:
```yaml
- name: Install Python development tools via uv
  shell: "{{ user_home }}/.local/bin/uv tool install {{ item }}"
  loop:
    - ruff
    - pyright
    - your-new-tool  # Add here
```

### Handling Conflicts
- Backup existing configs to `~/dotfiles-backups/` before stowing
- Use `mv` not `rm` to preserve user data
- Document backup location in output messages

## Testing Checklist

When making changes to automation:
- [ ] Test on fresh Ubuntu system if possible
- [ ] Verify WSL detection works correctly
- [ ] Check all symlinks created: `ls -la ~/.config/`
- [ ] Confirm tools accessible: `which nvim starship bat fd`
- [ ] Run ansible-playbook with `--check` first
- [ ] Test `stow.sh` install/uninstall/restow functions

## Maintenance Notes

- Neovim AppImage URL uses `/stable/` path (not `/nightly/`)
- Stow version: 2.3.1 (2019 release, stable)
- Ansible version: 9.2.0 with ansible-core 2.16.3
- Repository branch: `updates` (not `main`)
- Owner: vandercraig
