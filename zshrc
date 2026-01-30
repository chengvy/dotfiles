
export DOTHOME="$HOME/.config/dotfiles"
export ZSH="$HOME/.local/share/ohmyzsh"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

ZSH_CUSTOM="$DOTHOME/zsh"

ZSH_THEME="agnoster"

plugins=(git aliases)
plugins+=config
plugins+=cd-dirs
plugins+=dircycle
plugins+=z
plugins+=conda-zsh-completion
plugins+=zsh-autosuggestions
plugins+=zsh-syntax-highlighting

[[ -d $ZSH ]] && source $ZSH/oh-my-zsh.sh

#
unsetopt correct correct_all
