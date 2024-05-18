# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](https://iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# If using with "light" variant of the Solarized color schema, set
# SOLARIZED_THEME variable to "light". If you don't specify, we'll assume
# you're using the "dark" variant.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

prompt_start() {
    CURRENT_BG='NONE'

    case ${SOLARIZED_THEME:-dark} {
        (light) CURRENT_FG='white';;
        (*)     CURRENT_FG='black';;
    }

# Special Powerline characters

    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    # NOTE: This segment separator character is correct.  In 2012, Powerline changed
    # the code points they use for their special characters. This is the new code point.
    # If this is not working for you, you probably have an old version of the
    # Powerline-patched fonts installed. Download and install the new version.
    # Do not submit PRs to change this unless you have reviewed the Powerline code point
    # history and have new information.
    # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
    # what font the user is viewing this source code in. Do not replace the
    # escape sequence with a single literal character.
    # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
    SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]] {
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    } else {
        echo -n "%{$bg%}%{$fg%} "
    }
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
    if [[ -n $CURRENT_BG ]] {
        echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
    } else {
        echo -n "%{%k%}"
    }
    echo -n "%{%f%}"
    CURRENT_BG=''
}

prompt_conda() {
    if [[ -n "$CONDA_DEFAULT_ENV" ]] {
        prompt_segment red white "${CONDA_DEFAULT_ENV:gs/%/%%}"
    }
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
    if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]] {
        prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"
    }
}

# Git: branch/detached head, dirty status
prompt_git() {
    (( $+commands[git] )) || return
    if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]] {
        return
    }
    local PL_BRANCH_CHAR
    () {
        local LC_ALL="" LC_CTYPE="en_US.UTF-8"
        PL_BRANCH_CHAR=$'\ue0a0'         # 
    }
    local ref dirty mode repo_path

    if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]] {
        repo_path=$(git rev-parse --git-dir 2>/dev/null)
        dirty=$(parse_git_dirty)
        ref=$(git symbolic-ref HEAD 2> /dev/null) || \
        ref="◈ $(git describe --exact-match --tags HEAD 2> /dev/null)" || \
        ref="➦ $(git rev-parse --short HEAD 2> /dev/null)" 
        if [[ -n $dirty ]] {
            prompt_segment yellow black
        } else {
            prompt_segment green $CURRENT_FG
        }

        local ahead behind
        ahead=$(git log --oneline @{upstream}.. 2>/dev/null)
        behind=$(git log --oneline ..@{upstream} 2>/dev/null)
        if [[ -n "$ahead" ]] && [[ -n "$behind" ]] {
            PL_BRANCH_CHAR=$'\u21c5'
        } elif [[ -n "$ahead" ]] {
            PL_BRANCH_CHAR=$'\u21b1'
        } elif [[ -n "$behind" ]] {
            PL_BRANCH_CHAR=$'\u21b0'
        }

        if [[ -e "${repo_path}/BISECT_LOG" ]] {
            mode=" <B>"
        } elif [[ -e "${repo_path}/MERGE_HEAD" ]] {
            mode=" >M<"
        } elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]] {
            mode=" >R>"
        }

        # check for untracked files or updated submodules, since vcs_info doesn't
        local FMT_BRANCH="%c%u"
        if [[ -n "$(git ls-files --other --exclude-standard 2>/dev/null)" ]] {
            FMT_BRANCH+="%{%F{$CURRENT_FG}%} ?"
        }

        setopt promptsubst
        autoload -Uz vcs_info

        zstyle ':vcs_info:*' enable git
        zstyle ':vcs_info:*' get-revision true
        zstyle ':vcs_info:*' check-for-changes true
        zstyle ':vcs_info:*' unstagedstr "%{%F{red}%} ±"
        zstyle ':vcs_info:*' stagedstr "%{%F{green}%} ●"
        zstyle ':vcs_info:*' formats " ${FMT_BRANCH}"
        zstyle ':vcs_info:*' actionformats " ${FMT_BRANCH}"
        vcs_info
        echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
    }
}

prompt_bzr() {
    (( $+commands[bzr] )) || return

    # Test if bzr repository in directory hierarchy
    local dir="$PWD"
    while [[ ! -d "$dir/.bzr" ]]; do
        [[ "$dir" = "/" ]] && return
        dir="${dir:h}"
    done

    local bzr_status status_mod status_all revision
    if { bzr_status=$(bzr status 2>&1) } {
        status_mod=$(echo -n "$bzr_status" | head -n1 | grep "modified" | wc -m)
        status_all=$(echo -n "$bzr_status" | head -n1 | wc -m)
        revision=${$(bzr log -r-1 --log-format line | cut -d: -f1):gs/%/%%}
        if [[ $status_mod -gt 0 ]]  {
            prompt_segment yellow black "bzr@$revision ✚"
        } else {
            if [[ $status_all -gt 0 ]]  {
                prompt_segment yellow black "bzr@$revision"
            } else {
                prompt_segment green black "bzr@$revision"
            }
        }
    }
}

prompt_hg() {
    (( $+commands[hg] )) || return
    local rev st branch
    if { hg id &>/dev/null } {
        if { hg prompt &>/dev/null } {
            if [[ $(hg prompt "{status|unknown}") = "?" ]] {
                # if files are not added
                prompt_segment red white
                st='±'
            } elif [[ -n $(hg prompt "{status|modified}") ]] {
                # if any modification
                prompt_segment yellow black
                st='±'
            } else {
                # if working copy is clean
                prompt_segment green $CURRENT_FG
            }
            echo -n ${$(hg prompt "☿ {rev}@{branch}"):gs/%/%%} $st
        } else {
            st=""
            rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
            branch=$(hg id -b 2>/dev/null)
            if { hg st | grep -q "^\?" &>/dev/null } {
                prompt_segment red black
                st='±'
            } elif { hg st | grep -q "^[MA]" &>/dev/null } {
                prompt_segment yellow black
                st='±'
            } else {
                prompt_segment green $CURRENT_FG
            }
            echo -n "☿ ${rev:gs/%/%%}@${branch:gs/%/%%}" $st
        }
    }
}

# Dir: current working directory
prompt_dir() {
    local pwd="$PWD"
    local repo_path="${$(git rev-parse --git-dir 2>/dev/null)%/.git}"
    if [[ $pwd == $HOME* ]] {
        pwd="${pwd/#$HOME/~}"
        [[ -n $repo_path ]] && repo_path="${repo_path/#$HOME/~}"
    }
    local elems=(${(s:/:)pwd})
    local repo_idx=${(ws:/:)#repo_path}
    for ((i = 2; i < ${#elems}; i++)) {
        if (($i != $repo_idx)) {
            elems[i]="…"
        }
    }

    # local repo_dir=${repo_path[(ws:/:)-1]}
    pwd="${(j:/:)elems}"
    [[ $pwd != "~"* ]] && pwd="/$pwd"
    prompt_segment blue $CURRENT_FG "${pwd:gs/%/%%}"
    # prompt_segment blue $CURRENT_FG '%~'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
    if [[ -n "$VIRTUAL_ENV" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]] {
        prompt_segment blue black "(${VIRTUAL_ENV:t:gs/%/%%})"
    }
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
    local -a symbols

    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}󱐋" || symbols+="%{%F{white}%}"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"
    # [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"

    [[ -n "$symbols" ]] && prompt_segment "%(?.%(!.magenta.cyan).red)" default "$symbols"
}

#AWS Profile:
# - display current AWS_PROFILE name
# - displays yellow on red if profile name contains 'production' or
#   ends in '-prod'
# - displays black on green otherwise
prompt_aws() {
    [[ -z "$AWS_PROFILE" || "$SHOW_AWS_PROMPT" = false ]] && return
    case "$AWS_PROFILE" {
        (*-prod|*production*) prompt_segment red yellow  "AWS: ${AWS_PROFILE:gs/%/%%}" ;;
        (*) prompt_segment green black "AWS: ${AWS_PROFILE:gs/%/%%}" ;;
    }
}

## Main prompt
build_prompt() {
    RETVAL=$?
    prompt_start
    prompt_virtualenv
    prompt_aws
    prompt_context
    prompt_conda
    prompt_dir
    prompt_git
    prompt_bzr
    prompt_hg
    prompt_status
    prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
