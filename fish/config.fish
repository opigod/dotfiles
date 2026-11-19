source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
zoxide init fish | source
pyenv virtualenv-init - | source
# Default text editor: neovim.
# -Ux = universal (persists across sessions) AND exported to child processes.
# The export matters: `set -U` alone is invisible to sudoedit, git, crontab -e, etc.
set -Ux SUDO_EDITOR nvim
set -Ux VISUAL nvim
set -Ux EDITOR nvim

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
pyenv init - | source
pyenv virtualenv-init - | source
