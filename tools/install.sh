#!/usr/bin/env bash

USER=$(id -u -n)
HOME="${HOME:-$(getent passwd "$USER" 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~"$USER")}"

# default values for $DOTHOME and $ZSH
DOTHOME="${DOTHOME:-$HOME/.config/dotfiles}"
ZSH="${ZSH:-$HOME/.local/share/ohmyzsh}"

REPO=${REPO:-chengvy/dotfiles}
REMOTE=${REMOTE:-https://github.com/$REPO.git}
BRANCH=${BRANCH:-master}

command_exists() {
    command -v "$@" &>/dev/null
}

backup_file() {
    local file=$1
    if [[ -e "$file" ]]; then
        local backup
        backup="$file.bak-$(date +%Y-%m-%d_%H-%M-%S)"
        if [[ -e "$backup" ]]; then
            echo "$backup exists. Can't back up $file"
            echo "re-run again in a couple of seconds"
            return 1
        fi
        mv "$file" "$backup"
        echo "Found $file. Backing up to $backup"
    fi
}

link_file() {
    local src=$1
    local dest=$2
    if [[ -L "$dest" ]]; then
        if [[ "$src" == "$(readlink "$dest")" ]]; then
            echo "$dest is already linked to $src"
        else
            echo "Linked $dest (-> $(readlink "$dest")) to $src"
            ln -sf "$src" "$dest"
        fi
        return
    fi
    backup_file "$dest"
    ln -s "$src" "$dest"
    echo "Linked $dest to $src"
}

setup_dotfiles() {
    echo "Setting up dotfiles..."
    if [[ -d "$DOTHOME" ]]; then
        echo "The $DOTHOME folder already exists"
        return
    fi
    if ! command_exists git; then
        echo "Error: git is not installed"
        exit 1
    fi
    echo "Cloning dotfiles..."
    git clone --depth=1 --branch "$BRANCH" "$REMOTE" "$DOTHOME" || {
        [[ -d "$DOTHOME" ]] && rm -rf "$DOTHOME" &>/dev/null
        fmt_error "git clone of $REPO repo failed"
        exit 1
    }

}

setup_ohmyzsh() {
    echo "Setting up Oh My Zsh..."
    if [[ -d "$ZSH" ]]; then
        echo "The $ZSH folder already exists"
        return
    fi
    ZSH=$ZSH sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --keep-zshrc"
}

setup_nvim() {
    echo "Setting up nvim..."
    link_file "$DOTHOME/nvim" "$HOME/.config/nvim"

}

setup_config() {
    echo "Setting up config..."
    local DOT_CONFIG="$DOTHOME/config"
    link_file "$DOT_CONFIG/gitconfig" "$HOME/.gitconfig"
    link_file "$DOT_CONFIG/condarc" "$HOME/.condarc"
}

setup_zshrc() {
    echo "Setting up zshrc..."

    local dot=${DOTHOME/#$HOME\//"\$HOME/"}
    local omz=${ZSH/#$HOME\//"\$HOME/"}

    sed -e "s|^export DOTHOME=.*$|export DOTHOME=\"${dot}\"|" \
        -e "s|^export ZSH=.*$|export ZSH=\"${omz}\"|" -i "$DOTHOME/zshrc"
    link_file "$DOTHOME/zshrc" "$HOME/.zshrc"
}

setup_shell() {
    if [[ -z "$SHELL" ]]; then
        return 1
    fi
    if ! command_exists zsh; then
        return 1
    fi
    if [[ "$(basename -- "$SHELL")" == "zsh" ]]; then
        return
    fi
    echo "Changing shell to $(which zsh)"
    chsh -s "$(which zsh)" "$USER"
}

main() {
    if [[ ! -d "$(dirname "$DOTHOME")" ]]; then
        mkdir -p "$(dirname "$DOTHOME")"
    fi
    if [[ ! -d "$(dirname "$ZSH")" ]]; then
        mkdir -p "$(dirname "$ZSH")"
    fi

    setup_dotfiles
    setup_ohmyzsh

    setup_nvim
    setup_config

    if [[ -d "$ZSH" ]]; then
        setup_zshrc && setup_shell && exec zsh -l
    fi
}

main "$@"
