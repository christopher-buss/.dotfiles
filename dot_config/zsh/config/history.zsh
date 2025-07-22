### ---- History Configuration ----------------------------

HISTSIZE=10000
HISTFILESIZE=10000
SAVEHIST=9000

# Include timestamps in history entries
setopt EXTENDED_HISTORY

# Beep if attempting to access a history entry which isn’t there
setopt HIST_BEEP

# Trim dupes first if history is full
setopt HIST_EXPIRE_DUPS_FIRST

# Do not display previously found command
setopt HIST_FIND_NO_DUPS

# Do not save duplicate of prior command
setopt HIST_IGNORE_DUPS

# Do not save if line starts with space
setopt HIST_IGNORE_SPACE

# Do not save history commands
setopt HIST_NO_STORE

# Strip superfluous blanks
setopt HIST_REDUCE_BLANKS

# Don’t wait for shell to exit to save history lines
setopt INC_APPEND_HISTORY


