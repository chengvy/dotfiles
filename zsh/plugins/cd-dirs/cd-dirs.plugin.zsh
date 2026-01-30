
DIRSTACKSIZE=${DIRSTACKSIZE:-40}
DIRSTACKFILE=${DIRSTACKFILE:-$HOME/.cache/zsh/zdirs}

[[ -d ${DIRSTACKFILE:A:h} ]] || mkdir -p "${DIRSTACKFILE:A:h}"

if [[ -f $DIRSTACKFILE ]] && [[ -z $dirstack ]] {
    dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
    dirstack=( ${dirstack:#$PWD} )
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _chpwd_save_dirs

_chpwd_save_dirs() {
    local -aU _dirstack
    _dirstack=( $PWD $dirstack )
    builtin print -rl ${_dirstack[1,$DIRSTACKSIZE]} >| $DIRSTACKFILE
}

