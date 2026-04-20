# Icons
i_duck='󰇥'
i_branch=''
i_prompt='❯'

# Colors
c_icon='%F{11}'    # bright yellow
c_path='%F{12}'    # bright blue
c_branch='%F{13}'  # bright magenta
c_ok='%F{10}'      # bright green
c_err='%F{9}'      # bright red
c_reset='%f'

precmd() { _branch=$(git branch --show-current 2>/dev/null) }
setopt PROMPT_SUBST

PROMPT='${c_icon}${i_duck} ${c_path}%~${_branch:+ ${c_branch}${i_branch} ${_branch}${c_reset}}
%(?.${c_ok}.${c_err})${i_prompt} ${c_reset}'

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.secrets ]] && source ~/.secrets

eval "$(direnv hook zsh)"
source <(fzf --zsh)
