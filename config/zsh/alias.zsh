#!/bin/zsh


# ------------------------------------------------------------------------------
# aws: AWS Command Line Interface
# ------------------------------------------------------------------------------


if is_dotfiles_managed_package "aws"; then
    alias aws-account='aws sts get-caller-identity'
    alias aws-profile='aws configure list'
fi


# ------------------------------------------------------------------------------
# cd
# ------------------------------------------------------------------------------


# easier navigation: .., ..., ...., ....., and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"


# ------------------------------------------------------------------------------
# checksums
# ------------------------------------------------------------------------------


if command_exists "sha256sum"; then
    alias sha='sha256sum'
elif command_exists "shasum"; then
    alias sha='shasum -a 256'
fi


# ------------------------------------------------------------------------------
# docker: use OS-level virtualization to deliver software in containers
# ------------------------------------------------------------------------------


if is_dotfiles_managed_package "docker"; then

    # docker
    alias d='docker'

    # compose
    alias dc='docker-compose'

    # containers
    alias dps='docker ps'
    alias dpsa='docker ps -a'

    alias dcls='docker container ls'
    alias dci='docker container inspect'
    alias dcl='docker container logs'
    alias dcp='docker container port'

    alias dcs='docker container start'
    alias dcrs='docker container restart'
    alias dcsp='docker container stop'
    alias dcspa='docker container stop $(docker ps -q)'
    alias dcr='docker container run'
    alias dcex='docker container exec'

    alias dcrm='docker container rm'

    # images
    alias dils='docker image ls'
    alias dii='docker image inspect'

    alias dib='docker image build'
    alias dit='docker image tag'
    alias dipl='docker image pull'
    alias dip='docker image push'

    alias dipr='docker image prune'
    alias dirm='docker image rm'

    # networks
    alias dnls='docker network ls'
    alias dni='docker network inspect'

    alias dnc='docker network create'
    alias dnrm='docker network rm'

    # volumes
    alias dvls='docker volume ls'
    alias dvi='docker volume inspect'

    alias dvc='docker volume create'
    alias dvrm='docker volume rm'
    alias dvpr='docker volume prune'

    # system
    alias dsp='docker system prune'
    alias dsdf='docker system df'
    alias dsi='docker system info'
fi


# ------------------------------------------------------------------------------
# forgit: a utility tool powered by fzf for using git interactively
# ------------------------------------------------------------------------------


# git
alias g='git'


if is_dotfiles_managed_package "forgit"; then

    # add
    alias ga='forgit::add'
    alias gaa='git add --all'

    # attributes: settings that tell Git how to handle
    # specific files or paths within a repository
    alias gat='forgit::attributes'

    # blame
    alias gbl='forgit::blame'

    # branch
    alias gb='git branch'
    alias gba='git branch -a'
    alias gbd='forgit::branch::delete'

    # checkout
    alias gcb='forgit::checkout::branch'
    alias gcf='forgit::checkout::file'
    alias gco='forgit::checkout::commit'
    alias gct='forgit::checkout::tag'

    # cherry pick
    alias gcp='forgit::cherry::pick'
    alias gcpb='forgit::cherry::pick::from::branch'

    # clean: removes untracked files and directories
    alias gcln='forgit::clean'

    # commit
    alias gcm='git commit'
    alias gcma='git commit -a'
    alias gcmm='git commit --amend'

    # diff
    alias gd='forgit::diff'

    # fixup
    alias gf='forgit::fixup'

    # ignore
    alias gi='forgit::ignore'

    # log
    alias gl='forgit::log'

    # merge
    alias gm='git merge'

    # pull
    alias gpl='git pull'

    # push
    alias gph='git push'

    # rebase
    alias grb='forgit::rebase'

    # reflog
    alias grl='forgit::reflog'

    # reset
    alias grh='forgit::reset::head'

    # restore
    alias gr='git restore'
    alias grs='git restore --staged'

    # revert
    alias grc='forgit::revert::commit'

    # reword
    alias grw='forgit::reword'

    # stash
    alias gsa='git stash apply'
    alias gsclear='git stash clear'
    alias gsp='forgit::stash::push'
    alias gss='forgit::stash::show'

    # status
    alias gs='git status'

    # switch: dedicated solely to branch operations
    alias gsw='git switch'

    # tag
    alias gta='git tag'
    alias gt='git tag -a'
fi


# ------------------------------------------------------------------------------
# info: list misc info
# ------------------------------------------------------------------------------


alias ls-alias='alias | sort'
alias ls-env='env | sort'
alias ls-export-var='export -p | sort'
alias ls-fpath='print -l "${(@)fpath}" | sort'
alias ls-functions='print -l -- ${(k)functions} | sort'
alias ls-mpath='print -l "${(@)manpath}" | sort'
alias ls-path='print -l "${(@)path}" | sort'
alias ls-shell='echo $SHELL'
alias ls-shell-option='setopt | sort'
alias ls-shell-var='set | sort'


# ------------------------------------------------------------------------------
#
# kubectl: Kubernetes command line interface
#
# - References
#   - https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/kubectl.plugin.zsh
#
# ------------------------------------------------------------------------------


if is_dotfiles_managed_package "kubectl"; then

    alias k='kubectl'

    # apply
    alias kaf='kubectl apply -f'

    # configmap
    alias kgcm='kubectl get configmaps'
    alias kecm='kubectl edit configmap'
    alias kdcm='kubectl describe configmap'
    alias kdelcm='kubectl delete configmap'

    # contexts
    alias kc='kubectl config'
    alias kcg='kubectl config get-contexts'
    alias kcu='kubectl config use-context'
    alias kcs='kubectl config set-context'
    alias kcc='kubectl config current-context'

    # copy
    alias kcp='kubectl cp'

    # cronjob
    alias kgcj='kubectl get cronjob'
    alias kecj='kubectl edit cronjob'
    alias kdcj='kubectl describe cronjob'
    alias kdelcj='kubectl delete cronjob'

    # # daemonset
    # alias kgds='kubectl get daemonset'
    # alias kgdsw='kgds --watch'
    # alias keds='kubectl edit daemonset'
    # alias kdds='kubectl describe daemonset'
    # alias kdelds='kubectl delete daemonset'

    # deployment
    alias kgd='kubectl get deployment'
    alias kgdw='kubectl get deployment --watch'
    alias ked='kubectl edit deployment'
    alias kdd='kubectl describe deployment'
    alias kdeld='kubectl delete deployment'
    alias ksd='kubectl scale deployment'

    # exec
    alias keit='kubectl exec -it'

    # ingress
    alias kgi='kubectl get ingress'
    alias kei='kubectl edit ingress'
    alias kdi='kubectl describe ingress'
    alias kdeli='kubectl delete ingress'

    # job
    alias kgj='kubectl get job'
    alias kej='kubectl edit job'
    alias kdj='kubectl describe job'
    alias kdelj='kubectl delete job'

    # logs
    alias kl='kubectl logs'
    alias kl1h='kubectl logs --since 1h'
    alias kl1m='kubectl logs --since 1m'
    alias kl1s='kubectl logs --since 1s'
    alias klf='kubectl logs -f'
    alias klf1h='kubectl logs --since 1h -f'
    alias klf1m='kubectl logs --since 1m -f'
    alias klf1s='kubectl logs --since 1s -f'

    # namespae
    alias kgns='kubectl get namespaces'
    alias kens='kubectl edit namespace'
    alias kdns='kubectl describe namespace'
    alias kdelns='kubectl delete namespace'

    # node
    alias kgno='kubectl get nodes'
    alias keno='kubectl edit node'
    alias kdno='kubectl describe node'
    alias kdelno='kubectl delete node'

    # pod
    alias kgp='kubectl get pods'
    alias kgpw='kubectl get pods --watch'
    alias kep='kubectl edit pods'
    alias kdp='kubectl describe pods'
    alias kdelp='kubectl delete pods'

    # port forwarding
    alias kpf='kubectl port-forward'

    # # pvc
    # alias kgpvc='kubectl get pvc'
    # alias kgpvcw='kgpvc --watch'
    # alias kepvc='kubectl edit pvc'
    # alias kdpvc='kubectl describe pvc'
    # alias kdelpvc='kubectl delete pvc'

    # # rollout
    # alias kgrs='kubectl get rs'
    # alias krsd='kubectl rollout status deployment'
    # alias krh='kubectl rollout history'
    # alias kru='kubectl rollout undo'

    # secret
    alias kgsec='kubectl get secret'
    alias kdsec='kubectl describe secret'
    alias kdelsec='kubectl delete secret'

    # # service account
    # alias kdsa='kubectl describe sa'
    # alias kdelsa='kubectl delete sa'

    # # statefulset management.
    # alias kgss='kubectl get statefulset'
    # alias kgssw='kgss --watch'
    # alias kgsswide='kgss -o wide'
    # alias kess='kubectl edit statefulset'
    # alias kdss='kubectl describe statefulset'
    # alias kdelss='kubectl delete statefulset'
    # alias ksss='kubectl scale statefulset'
    # alias krsss='kubectl rollout status statefulset'

    # svc
    alias kgs='kubectl get svc'
    alias kgsw='kgs --watch'
    alias kes='kubectl edit svc'
    alias kds='kubectl describe svc'
    alias kdels='kubectl delete svc'
fi


# ------------------------------------------------------------------------------
# misc
# ------------------------------------------------------------------------------


# alias for my freq typo
alias celar='clear'


# ------------------------------------------------------------------------------
# network
# ------------------------------------------------------------------------------


alias ls-port='sudo lsof -i -P -n'
alias myip='curl ifconfig.me; echo'

if command_exists pppoeconf; then
    alias pppoe-on='sudo pon dsl-provider'
    alias pppoe-off='sudo poff -a'
fi


# ------------------------------------------------------------------------------
# python: Python programming language
# ------------------------------------------------------------------------------


{ command_exists "pip" } && alias ls-pip-package='pip list'


# ------------------------------------------------------------------------------
# ssh
# ------------------------------------------------------------------------------


# check connecting host
# https://www.baeldung.com/linux/list-connected-ssh-sessions
alias ssh-connecting='last | grep "still logged in"'

# list users that have ssh access through passwords
# https://askubuntu.com/questions/984912/how-to-get-the-list-of-all-users-who-can-access-a-server-via-ssh
if [[ -f "/etc/shadow" ]]; then
    alias ssh-users-haspassword='sudo cat /etc/shadow | grep "^[^:]*:[^\*!]" | cut -d ":" -f 1 | sort'
fi


# ------------------------------------------------------------------------------
# uuid
# ------------------------------------------------------------------------------


{ command_exists "uuidgen" } && alias uuid-gen='uuidgen'
