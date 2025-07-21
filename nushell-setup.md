# Nushell setup

## Starship

Create an init for nushell,

```nu
starship init nu | save --force ~/.cache/starship/init.nu
```

Add the following to `~/.config/nushell/config.nu`

```nu
# Set up Nushell and Starship environment variables
$env.STARSHIP_CONFIG = $"($env.HOME)/.config/starship.toml"
$env.STARSHIP_SHELL = "nu"

# Source the Starship initialization script
source ~/.cache/starship/init.nu
```
