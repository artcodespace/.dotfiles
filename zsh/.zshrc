# Use builtins to put git branch in top right
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b'
setopt PROMPT_SUBST

# Custom prompt duck, pwd, newline, chevron (red/green based on exit code)
PROMPT='%F{11}󰇥 %F{12}%~
%(?.%F{10}.%F{9})❯ %f'

# Custom right prompt for git
RPROMPT='[%F{13}${vcs_info_msg_0_}%f]'

# Source .zshrc.local for system specific stuff
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# External tools
eval "$(direnv hook zsh)"
source <(fzf --zsh)
