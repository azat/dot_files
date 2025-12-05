eval "$(/opt/homebrew/bin/brew shellenv)"

PATH="/opt/homebrew/opt/curl/bin:$PATH" >> ~/.zshrc
PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/binutils/bin:$PATH"
PATH="/opt/homebrew/opt/llvm/bin:$PATH"
PATH="/opt/homebrew/opt/rustup/bin:$PATH"
PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
# ch
PATH=~/src/ch/ClickHouse/build/programs:$PATH
# chdig
PATH=~/src/ch/chdig/target/release:$PATH

alias gg='git grep'
alias k=kubectl
alias mosh='MOSH_ESCAPE_KEY="" mosh'
alias xargs='xargs -r'
alias gsutil='PYTHONWARNINGS=ignore gsutil'
alias strings='strings -a'
alias gdb='gdb -q'
alias tm='tmux attach || tmux new'

eval "$(zoxide init zsh --cmd j --hook prompt)"
export _ZO_EXCLUDE_DIRS="${_ZO_EXCLUDE_DIRS:+$_ZO_EXCLUDE_DIRS:}"'~azat/Downloads/*'
export _ZO_EXCLUDE_DIRS="${_ZO_EXCLUDE_DIRS:+$_ZO_EXCLUDE_DIRS:}"'/tmp/*'

source <(fzf --zsh)
# Enter - eXecute command
# Ctrl-E - edit/accept
#
# Refs: https://github.com/junegunn/fzf/issues/477#issuecomment-2210222372
fzf-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
  # Ensure the module is loaded if not already, and the required features, such
  # as the associative 'history' array, which maps event numbers to full history
  # lines, are set. Also, make sure Perl is installed for multi-line output.
  if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
    selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} --expect=ctrl-e +m --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  else
    selected="$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} --expect=ctrl-e +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  fi
  local ret=$?
  if [[ -n $selected ]]; then
    if [[ $(sed -n '$=' <<<"$selected") -eq 1 ]]; then
      [[ $selected == "ctrl-e" ]] && LBUFFER="$selected"
    elif [[ $(sed '1d' <<<"$selected") =~ ^[[:space:]]*[[:digit:]]+ ]]; then
      zle vi-fetch-history -n "$MATCH"
      [[ $(sed 'q' <<<"$selected") != "ctrl-e" ]] && zle accept-line
     fi
  fi
  zle reset-prompt
  return $ret
}

# disable history sharing (default in oh-my-zsh)
setopt nosharehistory

# Notes:
# remove "/" to avoid splitting by it in readline (to match the bash behavior for zsh)
# remove ";" to make it bash compatible
# remove "." to make it bash compatible
export WORDCHARS='*?_-[]~=&!#$%^(){}<>'
# And make it more identical
autoload -U select-word-style
select-word-style bash
# P.S. This is not enough at least for Ctrl-W, and nothing from [1] helps.
#   [1]: https://unix.stackexchange.com/questions/250690/how-to-configure-ctrlw-as-delete-word-in-zsh

export EDITOR=nvim
alias vim=nvim

export K9S_FEATURE_GATE_NODE_SHELL=true
