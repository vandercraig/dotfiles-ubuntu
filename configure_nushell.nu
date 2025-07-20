# configure_nushell.nu
#
# Idempotent script to configure Nushell to use the Starship prompt
# with the 'bracketed-segments' theme.

# --- Configuration ---
let starship_config_path = $"($env.HOME)/.config/starship.toml"
let nu_config_dir = $"($env.HOME)/.config/nushell"
let nu_env_path = $"($nu_config_dir)/env.nu"
let starship_cache_dir = $"($env.HOME)/.cache/starship"
let starship_init_path = $"($starship_cache_dir)/init.nu"

# --- Helper Functions ---
def print-status [message: string] {
    print $"[INFO] ($message)"
}

def print-success [message: string] {
    print -e $"(ansi green)[SUCCESS](ansi reset) ($message)"
}

def print-warning [message: string] {
    print -e $"(ansi yellow)[WARNING](ansi reset) ($message)"
}

# --- Main Logic ---
def main [] {
    print-status "Starting Nushell and Starship configuration..."

    # Ensure necessary directories exist
    if not ($nu_config_dir | path exists) {
        mkdir $nu_config_dir
        print-success $"Created directory: ($nu_config_dir)"
    }
    if not ($starship_cache_dir | path exists) {
        mkdir $starship_cache_dir
        print-success $"Created directory: ($starship_cache_dir)"
    }

    # 1. Create Starship theme file if it doesn't exist
    if not ($starship_config_path | path exists) {
        print-status "Creating Starship config with 'bracketed-segments' preset..."
        starship preset bracketed-segments -o $starship_config_path
        print-success $"Starship config created at ($starship_config_path)"
    } else {
        print-warning "Starship config already exists, skipping creation."
    }

    # 2. Ensure main Nushell config sources the environment file
    let nu_config_path = $"($nu_config_dir)/config.nu"
    let source_line = "source env.nu"
    if not ($nu_config_path | path exists) {
        $source_line | save $nu_config_path
        print-success $"Created main Nushell config at ($nu_config_path)"
    } else {
        let content = open $nu_config_path
        if ($content | str find $source_line | is-empty) {
            $content | str join "\n" | str join $"\n($source_line)" | save $nu_config_path
            print-success $"Added 'source env.nu' to ($nu_config_path)"
        } else {
            print-warning $"'source env.nu' already present in ($nu_config_path)"
        }
    }

    # 3. Configure Nushell environment for Starship in env.nu
    let starship_env_line = '$env.STARSHIP_CONFIG = $"($env.HOME)/.config/starship.toml"'
    let starship_source_line = 'source ~/.cache/starship/init.nu'
    
    let env_content = if ($nu_env_path | path exists) { open $nu_env_path } else { "" }
    
    mut new_env_content = $env_content

    if ($env_content | str find '$env.STARSHIP_CONFIG' | is-empty) {
        $new_env_content = ($new_env_content | str join "\n\n# Set Starship configuration file\n" | str join $starship_env_line)
        print-success "Added STARSHIP_CONFIG to env.nu"
    } else {
        print-warning "STARSHIP_CONFIG already set in env.nu"
    }

    if ($env_content | str find 'source ~/.cache/starship/init.nu' | is-empty) {
        $new_env_content = ($new_env_content | str join "\n\n# Initialize Starship prompt\n" | str join $starship_source_line)
        print-success "Added Starship source to env.nu"
    } else {
        print-warning "Starship already sourced in env.nu"
    }

    if ($new_env_content != $env_content) {
        $new_env_content | save $nu_env_path
    }

    # 4. Generate the Starship init script for Nushell
    print-status "Generating Starship init script for Nushell..."
    starship init nu | save --force $starship_init_path
    print-success $"Starship init script generated at ($starship_init_path)"

    print-success "Configuration complete!"
}
