
# lazygit
alias lzg="lazygit"

# tmux
alias t="tmux"
alias tls="tmux ls"
alias tnew="tmux new -s"
alias tkill="tmux kill-session -t"
alias tkillw="tmux kill-window -t"
alias tkillp="tmux kill-pane -t"

if [[ -n $TMUX ]] {
    alias tsw="tmux switchc -t"
    alias tswl="tmux switchc -l"
} else {
    alias tsw="tmux attach -t"
    alias tswl="tmux attach"
}

