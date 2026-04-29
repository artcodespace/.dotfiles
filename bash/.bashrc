# Icons
i_duck='󰇥'
i_branch=''
i_prompt='❯'

# Colors
c_icon='\[\e[93m\]'    # bright yellow
c_path='\[\e[94m\]'    # bright blue
c_branch='\[\e[95m\]'  # bright magenta
c_ok='\[\e[92m\]'      # bright green
c_err='\[\e[91m\]'     # bright red
c_reset='\[\e[0m\]'

_set_prompt() {
    local exit_code=$?
    local chevron_color
    [[ $exit_code -eq 0 ]] && chevron_color="$c_ok" || chevron_color="$c_err"
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    local git_str=""
    [[ -n "$branch" ]] && git_str=" ${c_branch}${i_branch} ${branch}${c_reset}"
    PS1="${c_icon}${i_duck} ${c_path}\w${git_str}\n${chevron_color}${i_prompt} ${c_reset}"
}
PROMPT_COMMAND="_set_prompt"

[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
[[ -f ~/.secrets ]] && source ~/.secrets
export PATH="$HOME/.dotfiles/scripts:$PATH"

eval "$(direnv hook bash)"
source <(fzf --bash)
