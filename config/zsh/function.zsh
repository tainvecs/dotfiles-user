#!/bin/zsh


# ------------------------------------------------------------------------------
# docker: use OS-level virtualization to deliver software in containers
# ------------------------------------------------------------------------------


if is_dotfiles_managed_package "docker"; then

    # docker login
    if command_exists jq; then

        local -A _login_mapping=(
            [ghcr.io]='GitHub'
            [index.docker.io]='Docker Hub'
            [nvcr.io]='Nvidia'
            [registry.gitlab.com]='GitLab'
        )

        function ls-docker-login() {

            # docker config file
            local _docker_config_path
            if [[ -d $DOCKER_CONFIG && -f "$DOCKER_CONFIG/config.json" ]]; then
                _docker_config_path="$DOCKER_CONFIG/config.json"
            else
                _docker_config_path="$HOME/.docker/config.json"
            fi

            # check config file
            if [[ ! -f "$_docker_config_path" ]]; then
                log_message "docker config not found at '$_docker_config_path'" "error"
                return $RC_NOT_FOUND
            fi

            # parse config json
            local _docker_login_auths
            _docker_login_auths=$(jq -r '.auths' "$_docker_config_path")
            if [[ "$_docker_login_auths" == "null" ]]; then
                log_message "no docker login found." "info"
                return $RC_SUCCESS
            fi

            local -a _docker_login_uri_lines
            _docker_login_uri_lines=("${(@f)$(echo $_docker_login_auths | jq 'keys | .[]')}")

            # check if login array is empty
            if [[ ${#_docker_login_uri_lines[@]} -eq 0 ]]; then
                log_message "no docker login found." "info"
                return $RC_SUCCESS
            fi

            # process by line
            local -a _array
            for _line in "${_docker_login_uri_lines[@]}"; do

                # process URL (strip protocol and trailing quotes)
                local _url_line=$(sed -re 's#\"?(https?://)?([^/]+)#\2#' \
                                      -e 's/\"$//' \
                                      <<< $_line)

                # match login mapping
                local _registry="-"
                for _key _val in "${(@kv)_login_mapping}"; do
                    [[ "$_url_line" == "$_key"* ]] && _registry="$_val" && break
                done

                # result
                local _processed_line=$(printf '%-15.15s %s\n' "$_registry" "$_url_line")
                _array+=("$_processed_line")
            done

            # sort
            local -a _sorted_lines
            IFS=$'\n' _sorted_lines=($(sort <<< "${_array[*]}"))
            unset IFS

            # output header and sorted lines
            printf '%-15.15s %s\n' "REGISTRY" "URL"
            printf '=%.0s' {1..15}
            printf ' '
            printf '=%.0s' {1..30}
            printf '\n'

            for _line in "${_sorted_lines[@]}"; do
                echo "$_line"
            done
        }
    fi
fi


# ------------------------------------------------------------------------------
# fail2ban
# ------------------------------------------------------------------------------


if command_exists "fail2ban-client"; then

    if command_exists "sqlite3"; then

        function f2b-jails-ls(){

            if [[ $1 == '-h' || $1 == '--help' ]]; then
                log_message "List all jails." "info"
            else
                raw_res_str=$(sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3 "SELECT name, enabled FROM jails;")
                res_str=$(echo $raw_res_str | sed 's/|/\t/g')

                log_message "JAIL\tENABLED" "info"
                log_message "$res_str" "info"
            fi
        }

        function f2b-baned-ls(){

            if [[ $1 == '-h' || $1 == '--help' ]]; then
                log_message "List all baned ip." "info"
            else
                raw_res_str=$(sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3 "SELECT jail, ip FROM bips;")
                res_str=$(echo $raw_res_str | sed 's/|/\t/g')

                log_message "JAIL\tIP" "info"
                log_message "$res_str" "info"
            fi
        }
    fi

    # sshd
    if command_exists "sqlite3"; then

        function f2b-sshd-baned-ls(){
            if [[ $1 == '-h' || $1 == '--help' ]]; then
                log_message "List all sshd baned ip." "info"
            else
                raw_res_str=$(sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3 "SELECT jail, ip FROM bips WHERE jail='sshd';")
                res_str=$(echo $raw_res_str | sed 's/|/\t/g')

                log_message "JAIL\tIP" "info"
                log_message "$res_str" "info"
            fi
        }

        function f2b-sshd-baned-find(){
            if [[ $1 == '-h' || $1 == '--help' || $1 == '' ]]; then
                log_message "Find an ip $1 in sshd jail." "info"
                log_message "$1: ip" "info"
            else
                raw_res_str=$(sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3 "SELECT jail, ip FROM bips WHERE jail='sshd' and ip='$1';")
                res_str=$(echo $raw_res_str | sed 's/|/\t/g')

                log_message "JAIL\tIP" "info"
                log_message "$res_str" "info"
            fi
        }

        function f2b-sshd-baned-count(){
            if [[ $1 == '-h' || $1 == '--help' ]]; then
                log_message "Count banned ip in sshd jail." "info"
            else
                sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3 "SELECT COUNT(*) FROM bips WHERE jail='sshd';"
            fi
        }
    fi

    function f2b-sshd-status(){
        if [[ $1 == '-h' || $1 == '--help' ]]; then
            log_message "sshd: status." "info"
        else
            sudo fail2ban-client status sshd
        fi
    }

    function f2b-sshd-reload(){
        if [[ $1 == '-h' || $1 == '--help' ]]; then
            log_message "sshd: reload config." "info"
        else
            sudo fail2ban-client reload sshd
            sudo fail2ban-client status sshd
        fi
    }

    function f2b-sshd-ban(){
        if [[ $1 == '-h' || $1 == '--help' || $1 == '' ]]; then
            log_message "sshd: ban an ip $1." "info"
            log_message "$1: ip" "info"
        else
            sudo fail2ban-client set sshd banip $1
        fi
    }

    function f2b-sshd-unban(){
        if [[ $1 == '-h' || $1 == '--help' || $1 == '' ]]; then
            log_message "sshd: unban an ip $1." "info"
            log_message "$1: ip" "info"
        else
            sudo fail2ban-client set sshd unbanip $1
        fi
    }
fi


# ------------------------------------------------------------------------------
# git
# ------------------------------------------------------------------------------


# git prune local branches
function gp(){

    git fetch

    # Prune origin (remote)
    local _git_origin_ready_prune_output=$(git remote prune origin --dry-run)
    if [[ -n "$_git_origin_ready_prune_output" ]]; then
        log_message "$_git_origin_ready_prune_output" "info"
        while true; do
            read -r "?Do you want to prune these remote branches? (y/n) " yn
            case $yn in
                [Yy]* ) git remote prune origin; break ;;
                [Nn]* ) break ;;
                * ) log_message "Please answer yes or no." "info" ;;
            esac
        done
    fi

    # Prune local branches tracking gone remotes
    local _git_filtered_branches=$(git branch -vv | grep ': gone]' | awk '{print $1}')
    if [[ -n "$_git_filtered_branches" ]]; then
        log_message "$_git_filtered_branches" "info"
        local -a _git_filtered_branch_array=("${(f)_git_filtered_branches}")
        while true; do
            read -r "?Do you want to prune these local branches? (y/n) " yn
            case $yn in
                [Yy]* ) for rm_branch in "${_git_filtered_branch_array[@]}"; do
                            git branch -D "$rm_branch"
                        done
                        break ;;
                [Nn]* ) break ;;
                * ) log_message "Please answer yes or no." "info" ;;
            esac
        done
    fi

    # If nothing to prune
    if [[ -z "$_git_filtered_branches" && -z "$_git_origin_ready_prune_output" ]]; then
        log_message "No branches to be pruned." "info"
    fi
}


# ------------------------------------------------------------------------------
# hyperfine
# ------------------------------------------------------------------------------


function bm(){
    hyperfine --shell zsh 'zsh -ic "'$1'"'
}

function bm-zsh(){
    hyperfine --shell zsh 'zsh -ic exit;'
}


# ------------------------------------------------------------------------------
#
# info: list misc info
#
# - Reference
#
#   - completion
#     - https://stackoverflow.com/questions/40010848/how-to-list-all-zsh-autocompletions
#
#   - links
#     - https://unix.stackexchange.com/questions/34248/how-can-i-find-broken-symlinks
#
#   - string processing
#     - https://stackoverflow.com/questions/10520623/how-to-split-one-string-into-multiple-variables-in-bash-shell
#     - https://unix.stackexchange.com/questions/396223/bash-shell-script-output-alignment
#     - https://superuser.com/questions/284187/how-to-iterate-over-lines-in-a-variable-in-bash
#     - https://unix.stackexchange.com/questions/35469/why-does-ls-sorting-ignore-non-alphanumeric-characters
#     - https://askubuntu.com/questions/595269/use-sed-on-a-string-variable-rather-than-a-file
#     - https://askubuntu.com/questions/678915/whats-the-difference-between-and-in-bash
#     - https://stackoverflow.com/questions/3618078/pipe-only-stderr-through-a-filter
#
# ------------------------------------------------------------------------------


# ----- completion
function ls-completion() {

    local _command _completion

    # print header
    printf '%-60s %s\n' "COMMAND" "COMPLETION"
    printf '%s\n' "$(printf '=%.0s' {1..60}) $(printf '=%.0s' {1..60})"

    # list and format completions
    for _command _completion in ${(kv)_comps:#-*(-|-,*)}; do
        printf "%-60s %s\n" "$_command" "$_completion"
    done | LC_ALL=C sort
}

# ----- link
# Helper function to find symbolic links
# - $1: max depth to search (must be a positive number)
# - $2: directory to search (optional, defaults to ".")
function _find_symlinks() {

    local _max_depth _dir _type

    # Validate max depth argument
    if [[ -z "$1" || ! "$1" =~ ^[0-9]+$ || "$1" -le 0 ]]; then
        log_message "invalid or missing argument: '$1'" "error"
        log_message "Usage: $2 <max-depth> [directory]" "info"
        return $RC_INVALID_ARGS
    fi
    _max_depth="$1"

    # Set directory to search (default: current directory)
    _dir="${2:-.}"

    # Validate directory existence
    if [[ ! -d "$_dir" ]]; then
        log_message "'$_dir' is not a valid directory" "error"
        return $RC_ERROR
    fi

    # Select find type (all symlinks or broken ones)
    _filter_str="${3:--type l}"  # Default: find all symlinks
    _filter_arr=(${=_filter_str})

    # Find symbolic links and sort results
    find "$_dir" -maxdepth "$_max_depth" "${_filter_arr[@]}" | sort
}

# List symbolic links
# - $1: max depth to search (must be a positive number)
# - $2: directory to search (optional, defaults to ".")
function ls-link() {
    _find_symlinks "$1" "$2" "-type l"
}

# List broken symbolic links
# - $1: max depth to search (must be a positive number)
# - $2: directory to search (optional, defaults to ".")
function ls-link-broken() {
    _find_symlinks "$1" "$2" "-type l ! -exec test -e {} ; -print"
}


# ------------------------------------------------------------------------------
# kubectl: Kubernetes command line interface
# ------------------------------------------------------------------------------


function kcns() {
    kubectl config set-context --current --namespace=$1
}


# ------------------------------------------------------------------------------
#
# linux
#
# - Reference
#   - https://askubuntu.com/questions/148932/how-can-i-get-a-list-of-all-repositories-and-ppas-from-the-command-line-into-an#comment2564796_148968
#
# ------------------------------------------------------------------------------


if [[ "$DOTFILES_SYS_NAME" == "linux" ]]; then

    # list apt sources
    function ls-apt-source() {

        local _raw_source_str _source_str _src _type _opt _uri

        # list and filter APT source files
        _raw_source_str=$(grep -r --include '*.list' '^deb ' '/etc/apt/' 2>/dev/null) || return

        # process the string with sed for formatting
        _source_str=$(sed -re 's/\/etc\/apt\/(sources\.list(:| ))/\1/' \
                          -e 's/^\/etc\/apt\/sources\.list\.d\///' \
                          -e 's/[:]?(deb(-src)?) /@ \1@ /' \
                          -e 's/deb http:\/\/ppa.launchpad.net\/(.*?)\/ubuntu .*/ppa:\1/' \
                          -e 's/ (https?:[^ ]+) /@ \1@ /' \
                          -e 's/\s+//g' \
                          <<< $_raw_source_str)

        # split and format output
        while IFS='@' read -r _src _type _opt _uri _; do
            printf "Source File: %s\n" "${_src:--}"
            printf "Type:        %s\n" "${_type:--}"
            printf "URI:         %s\n" "${_uri:--}"
            printf "Options:     %s\n\n" "${_opt:--}"
        done <<< $(LC_ALL=C sort <<< "$_source_str")
    }

    # apt gpg key
    function ls-apt-key() {
        apt-key list 2> >(grep -v 'Warning:' >&2)
    }

    function ls-apt-package() {

        # print header
        printf '%-43.43s %-40.40s %-12.12s %-80.80s\n' "NAME" "VERSION" "ARCHITECTURE" "SUMMARY"
        printf '=%.0s' {1..43}
        printf ' '
        printf '=%.0s' {1..40}
        printf ' '
        printf '=%.0s' {1..12}
        printf ' '
        printf '=%.0s' {1..80}
        printf '\n'

        # process package information directly from dpkg-query
        dpkg-query -W -f '${Package},${Version},${Architecture},${binary:Summary}\n' | LC_ALL=C sort | \
            while IFS=',' read -r _name _ver _archt _summary; do
                printf '%-43s %-40s %-12s %-80s\n' "$_name" "$_ver" "$_archt" "$_summary"
            done
    }
fi


# ------------------------------------------------------------------------------
# python: Python programming language
# ------------------------------------------------------------------------------


if is_dotfiles_managed_package "python"; then

    function ls-pip-freeze() {

        # print header
        printf '%-30.30s %s\n' "PACKAGE" "VERSION"
        printf '=%.0s' {1..30}
        printf ' '
        printf '=%.0s' {1..30}
        printf '\n'

        # Read pip freeze output into an array
        local -a _pip_lines
        _pip_lines=("${(@f)$(pip freeze | sed -E 's/( )*(==|@)( )*/==/g' | sort)}")

        # Process each line
        for _line in "${_pip_lines[@]}"; do
            # split with ==
            local _name=${_line%==*}
            local _ver=${_line#*==}

            # print
            printf '%-30.30s %s\n' "$_name" "$_ver"
        done
    }
fi


# ------------------------------------------------------------------------------
# macOS
# ------------------------------------------------------------------------------


if [[ "$DOTFILES_SYS_NAME" == "mac" ]]; then

    function mac-cleanup() {

        # recursively delete `.DS_Store` files
        find . -type f -name '*.DS_Store' -ls -delete

        if type brew>/dev/null; then
            brew doctor
            brew cleanup -s
            brew cleanup --prune=all
        fi
    }

    # show/hide hidden files
    function mac-finder-show() {
        defaults write com.apple.finder AppleShowAllFiles TRUE
        killall Finder
        log_message "Finder show hidden file mode was set to True." "info"
    }
    function mac-finder-hide() {
        defaults write com.apple.finder AppleShowAllFiles FALSE
        killall Finder
        log_message "Finder show hidden file mode was set to False." "info"
    }

    # hide/show all desktop icons (useful when presenting)
    function mac-desktop-show() {
        defaults write com.apple.finder CreateDesktop TRUE
        killall Finder
        log_message "Desktop show icons mode was set to True." "info"
    }
    function mac-desktop-hide() {
        defaults write com.apple.finder CreateDesktop FALSE
        killall Finder
        log_message "Desktop show icons mode was set to False." "info"
    }

    # afk
    function afk(){
        osascript -e 'tell app "System Events" to key code 12 using {control down, command down}'
    }
fi


# ------------------------------------------------------------------------------
# random number
# ------------------------------------------------------------------------------


if command_exists "shuf"; then
    function rand(){
        shuf -i ${1:-0-99} -n ${2:-1}
    }
fi


# ------------------------------------------------------------------------------
# timestamp
# ------------------------------------------------------------------------------


function timestamp-gen(){
    date +%s
}

function timestamp-decode(){
    strftime "%c UTC%z" $1
}

function timestamp-decode-utc(){
    TZ="UTC" strftime "%c UTC%z" $1
}


# ------------------------------------------------------------------------------
# update
# ------------------------------------------------------------------------------


function update(){

    # mac
    if [[ $1 == "" || $1 == "mac" ]] && [[ "$DOTFILES_SYS_NAME" == "mac" ]]; then
        sudo softwareupdate -i -a;
        if command_exists "brew"; then
            brew update
            brew upgrade
        fi
    fi

    # linux
    if [[ $1 == "" || $1 == "linux" ]] && [[ "$DOTFILES_SYS_NAME" == "linux" ]]; then
        sudo apt update
        sudo apt upgrade
    fi

    # zinit
    if [[ $1 == "" || $1 == "zinit" ]] && { command_exists zinit }; then
        zinit self-update
        zinit update --all
    fi

    # emacs
    if [[ $1 == "" || $1 == "emacs" ]] && { command_exists emacs }; then
        eval "emacs --eval '(progn (sit-for 2) (auto-package-update-now) (sit-for 2) (save-buffers-kill-terminal))'"
    fi
}


# ------------------------------------------------------------------------------
#
# vim
#
# - Reference
#   - https://stackoverflow.com/questions/25520709/html-conversion-with-vimdiff-in-shell-script
# ------------------------------------------------------------------------------


if is_dotfiles_managed_package "vim"; then
    function vimdiff2html(){
        vimdiff $1 $2 -c TOhtml -c "w! $3" -c "qa!"
    }
fi
