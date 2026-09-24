unset zle_bracketed_paste

source ~/.profile
# Must follow .profile: -U dedupes when applied, not on later PATH= assignments
typeset -U path

# Keeps `= 2 * 3` from globbing; `alias` syntax can't name `=`
aliases[=]='noglob ='

setopt auto_cd

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

autoload -Uz vcs_info
precmd_functions+=(vcs_info)
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{green}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{green}(%b|%a)%f'
setopt prompt_subst
PROMPT='%n@%m %1~${vcs_info_msg_0_} %# '

command -v direnv >/dev/null && eval "$(direnv hook zsh)"
