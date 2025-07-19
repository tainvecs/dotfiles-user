# dotfiles User

This repository provides an example for the [dotfiles] user directory. It includes user-customized configs, envs, secrets, manuals, and completions.

## Prerequisite
- [dotfiles]

## Installation
Users can reference or fork this repository to create their own [dotfiles] user directory.

To quickly get started with this user repository, run the following commands in the [dotfiles] directory:
```zsh
# Clone this example repository to dotfiles/user
git clone git@github.com:tainvecs/dotfiles-user.git user

# Replace the current shell process with a new zsh process
exec zsh
```

## Overview
The table below lists the packages managed by [dotfiles]. [dotfiles] manages the installation and configuration of these.

### Packages
| Name                      | Mac Installation | Ubuntu Installation | User Config                               | User Secret     | Default Enabled |
|:--------------------------|:----------------:|:-------------------:|:------------------------------------------|:----------------|:---------------:|
| 7z                        | ✅               | ✅                  |                                           |                 |                 |
| alt-tab                   | ✅               |                     |                                           |                 |                 |
| autoenv                   | ✅               | ✅                  |                                           |                 | ✅              |
| aws                       | ✅               | ✅                  | aws/config                                | aws/credentials |                 |
| bat                       | ✅               | ✅                  | bat/bat.conf                              |                 | ✅              |
| delta                     | ✅               | ✅                  | delta/config                              |                 | ✅              |
| docker                    | ✅               | ✅                  | docker/config.json,<br>docker/daemon.json |                 | ✅              |
| docker-credential-helpers | ✅               | ✅                  |                                           |                 | ✅              |
| duf                       | ✅               | ✅                  |                                           |                 | ✅              |
| dust                      | ✅               | ✅                  |                                           |                 | ✅              |
| emacs                     | ✅               | ✅                  | emacs/init.el                             |                 |                 |
| extract                   | ✅               | ✅                  |                                           |                 | ✅              |
| eza                       | ✅               | ✅                  |                                           |                 | ✅              |
| fast-syntax-highlighting  | ✅               | ✅                  |                                           |                 | ✅              |
| fd                        | ✅               | ✅                  |                                           |                 | ✅              |
| forgit                    | ✅               | ✅                  |                                           |                 | ✅              |
| fzf                       | ✅               | ✅                  |                                           |                 | ✅              |
| gcp                       | ✅               | ✅                  | gcp/config_default                        |                 |                 |
| go                        | ✅               | ✅                  |                                           |                 |                 |
| htop                      | ✅               | ✅                  | htop/htoprc                               |                 | ✅              |
| iterm                     | ✅               |                     |                                           |                 |                 |
| jdk                       | ✅               | ✅                  |                                           |                 | ✅              |
| keyd                      |                  | ✅                  | keyd/default.conf                         |                 |                 |
| kubectl                   | ✅               | ✅                  | kubectl/config                            | kubectl/config  |                 |
| nvitop                    |                  | ✅                  |                                           |                 |                 |
| peco                      | ✅               | ✅                  | peco/config.json                          |                 |                 |
| powerlevel10k             | ✅               | ✅                  | powerlevel10k/p10k.zsh                    |                 | ✅              |
| pyenv                     | ✅               | ✅                  |                                           |                 |                 |
| python                    | ✅               | ✅                  | python/.pythonrc                          |                 | ✅              |
| ripgrep                   | ✅               | ✅                  | ripgrep/.ripgreprc                        |                 | ✅              |
| tmux                      | ✅               | ✅                  | tmux/.tmux.conf                           |                 |                 |
| oh-my-tmux                | ✅               | ✅                  | tmux/.tmux.conf                           |                 |                 |
| tree                      | ✅               | ✅                  |                                           |                 | ✅              |
| universalarchive          | ✅               | ✅                  |                                           |                 | ✅              |
| vim                       | ✅               | ✅                  | vim/.vimrc, vim/colors                    |                 |                 |
| volta                     | ✅               | ✅                  | volta/.npmrc                              |                 |                 |
| vscode                    | ✅               | ✅                  |                                           |                 |                 |
| watch                     | ✅               |                     |                                           |                 |                 |
| zoxide                    | ✅               | ✅                  |                                           |                 | ✅              |
| zsh-autosuggestions       | ✅               | ✅                  | zsh-autosuggestions/config.zsh            |                 | ✅              |
| zsh-completions           | ✅               | ✅                  |                                           |                 | ✅              |

### Built-in Configurations
| Name | User Config                                 | User Secret |
|:-----|:--------------------------------------------|:------------|
| git  | git/config                                  |             |
| ssh  | ssh/config                                  | ssh/keys/   |
| zsh  | zsh/.zshrc, zsh/alias.zsh, zsh/function.zsh |             |

### Directory Structure
```
dotfiles/user
├── completion
├── config
├── env
├── history
├── man
└── secret
```
- `env`
  - Some packages are enabled by default. Update the env variable `DOTFILES_USER_PACKAGE_ARR` to enable or disable packages. See the example [here](https://github.com/tainvecs/dotfiles-user/blob/main/env/package.env).
  - All files with the `.env` extension will be sourced by `.zshrc` when the shell starts. Users can create their own env files.
- `config`
  - Refer to the `User Config` columns in the Packages and Built-in Configurations tables, and create the respective configuration files in this `config` folder. They will be automatically linked to the `dotfiles/.local` directory when the shell starts.
  - To manage more than one set of configurations for different computers, users can set the environment variable `DOTFILES_USER_PROFILE`. For example, add this line of code to your `~/.zshenv`:
    ```zsh
    export DOTFILES_USER_PROFILE=my_profile
    ```
    This profile will be used as a prefix (e.g., `my_profile-`) to match configuration files, such as `aws/my_profile-config`, and will fall back to `aws/config` if `aws/my_profile-config` is not found.
- `secret`
  - Similar to the `config` directory, refer to the `User Secret` columns and create the respective secret files or directories.
  - The user profile environment variable works the same way as in the config section.
- `completion`
  - This directory is added to `fpath`. Users can create their own Zsh completion files in this directory.
  - If completions are not autoloaded, run the following commands to clear the cache and reinitialize the Zsh completion system:
    ```zsh
    rm $DOTFILES_ZSH_COMPDUMP_PATH
    zpcompinit
    zpcdreplay
    ```
- `man`
  - Similar to the `completion` directory, the `man` directory is added to the `manpath`. Put custom manuals in this directory.
- `history`
  - Some history files, such as `.zsh_history` or `.python_history` in the dotfiles `XDG_STATE_HOME` directory, will be linked to this directory for easier reference.


[dotfiles]: https://github.com/tainvecs/dotfiles
