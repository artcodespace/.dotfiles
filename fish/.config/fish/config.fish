# Icons
set -g i_duck '󰇥'
set -g i_branch ''
set -g i_prompt '❯'

# Colors
set -g c_icon bryellow    # bright yellow
set -g c_path brblue      # bright blue
set -g c_branch brmagenta # bright magenta
set -g c_ok brgreen       # bright green
set -g c_err brred        # bright red

function fish_prompt
    set -l last_status $status
    set -l chevron_color (test $last_status -eq 0 && echo $c_ok || echo $c_err)
    set -l branch (git branch --show-current 2>/dev/null)
    echo -n (set_color $c_icon)$i_duck' '(set_color $c_path)(prompt_pwd)
    if test -n "$branch"
        echo -n (set_color $c_branch)' '$i_branch' '$branch
    end
    set_color normal
    echo
    echo -n (set_color $chevron_color)$i_prompt' '(set_color normal)
end

# Parse ~/.secrets (export KEY=VALUE format)
if test -f ~/.secrets
    while read -l line
        string match -qr '^\s*#' -- $line; and continue
        string match -qr '^\s*$' -- $line; and continue
        if string match -qr '^export\s+\w+=' -- $line
            set -l stripped (string replace -r '^export\s+' '' $line)
            set -l key (string replace -r '=.*' '' $stripped)
            set -l value (string replace -r '^[^=]+=(.*)'  '$1' $stripped)
            if string match -qr '^".*"$' -- $value
                set value (string sub -s 2 -e -1 $value)
            else if string match -qr "^'.*'\$" -- $value
                set value (string sub -s 2 -e -1 $value)
            end
            set -gx $key $value
        end
    end < ~/.secrets
end

if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end

direnv hook fish | source
fzf --fish | source
