eval "$(direnv hook zsh)"
source <(fzf --zsh)

# Custom prompt duck, pwd, newline, chevron (red/green based on exit code)
PROMPT='%F{11}󰇥 %F{12}%~
%(?.%F{10}.%F{9})❯ %f'

# Source .zshrc.local for system specific stuff
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
