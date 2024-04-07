. $HOME/.cargo/env
. $HOME/.zshenv_private
###################################
########    ALIASES     ###########
###################################
alias vim='nvim'
alias python='python3'
alias e='exa -lah --group-directories-first'
alias tmx='tmux a -t main || tmux new -s main'

# Kubernetes
alias kdelpf='kubectl delete pods --grace-period=0 --force'
alias kcx='kubectx'

# Git
alias git-delete-stale-branches="git fetch -p && git branch -vv | awk '/: gone]/{print \$1}' | xargs git branch -D"
