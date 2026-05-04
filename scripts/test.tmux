# STRUCTURE, in parens is optional
# window(*) window-name (layout)
# - window const
# - (*) const
# - window-name string
# - (layout) horizontal | vertical
# pane(*) command
# - pane const
# - (*) const
# - command string
window* first-one horizontal
pane* lazygit
pane nvim

hello!
window second-one vertical
pane top
pane
pane fzf
