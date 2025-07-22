#!/usr/bin/env zsh

# -- Select all --
# Key: ctrl+a
.zle_select-all () {
  (( CURSOR=0 ))
  (( MARK=$#BUFFER ))
  (( REGION_ACTIVE=1 ))
  if (( $+functions[_zsh_highlight] )); then _zsh_highlight; fi
}
  
zle -N       .zle_select-all
bindkey '^A' .zle_select-all  # ctrl+a

.zshrc_def-del-selected-or () {  # <name> <wrapped-zle> <keyseq>...
  eval "
    .zle_del-selected-or-$1 () {
      if (( REGION_ACTIVE )) {
        zle .kill-region
      } else {
        zle $2
      }
      if (( \$+functions[_zsh_highlight] ))  _zsh_highlight
    }
    zle -N                                         .zle_del-selected-or-$1
    for keyseq ( ${(q)@[3,-1]} )  bindkey \$keyseq .zle_del-selected-or-$1
  "
}

.zle_backspace-or-undo () {
  if [[ $LASTWIDGET == *complet* ]] {
    zle .undo
  } else {
    zle .backward-delete-char
  }
}
zle -N .zle_backspace-or-undo

() {
  emulate -L zsh

  local keyseq

  .zshrc_def-del-selected-or bksp    .zle_backspace-or-undo '^?'                      # backspace
  .zshrc_def-del-selected-or del     .delete-char           '^[[3~' "^[3'5~" '\e[3~'  # delete
}
unfunction .zshrc_def-del-selected-or