# shellcheck shell=bash

function zshrc() {
  export ASDF_DATA_DIR=$XDG_DATA_HOME/asdf
  export ASDF_DIR=/opt/asdf-vm
  export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=$XDG_CONFIG_HOME/asdf/tool_versions
  export CARGO_HOME=$XDG_CACHE_HOME/cargo
  path+=$CARGO_HOME/bin
  export CYPRESS_CACHE_FOLDER=$XDG_CACHE_HOME/cypress
  export GRIPHOME=$XDG_CACHE_HOME/grip
  export HISTFILE=$XDG_DATA_HOME/zsh/history
  export LESS=-iRFXMx4
  export LESSHISTFILE=$XDG_CACHE_HOME/less/history
  export LPASS_AGENT_TIMEOUT=86400
  export LPASS_HOME=$XDG_CACHE_HOME/lpass
  export NO_UPDATE_NOTIFIER=1
  export NODE_REPL_HISTORY=$XDG_DATA_HOME/node_repl_history
  export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm
  export PAGER=less
  export PIPX_HOME=$XDG_CACHE_HOME/pipx
  export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep/ripgreprc
  export TMUX_PLUGIN_MANAGER_PATH=$XDG_CACHE_HOME/tmux/plugins

  mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"
  mkdir -p "$(dirname "$HISTFILE")"
  mkdir -p "$(dirname "$LESSHISTFILE")"

  if command -v gh &>/dev/null; then
    eval "$(gh completion -s zsh)"
  fi

  if command -v spt &>/dev/null; then
    # shellcheck disable=SC1090
    source <(spt --completions zsh | head -n -1 | tail -n +2)
    compdef _spt spt
  fi

  if command -v pipx &>/dev/null; then
    eval "$(register-python-argcomplete pipx)"
  fi

  if command -v tig &>/dev/null; then
    mkdir -p "$XDG_DATA_HOME"/tig
  fi

  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --no-config'
  fi

  if [ -v WSLENV ]; then
    local LOCAL_ADDRESS
    LOCAL_ADDRESS=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null)
    export DISPLAY=$LOCAL_ADDRESS:0.0
    export PULSE_SERVER=tcp:$LOCAL_ADDRESS
    export LPASS_CLIPBOARD_COMMAND=clip.exe
  fi

  ###############################################################################

  alias sudo='nocorrect sudo -E '

  if command -v bat &>/dev/null; then
    alias cat='bat --pager=never'
  fi

  alias c="printf '\n%.0s' {1..100}"

  if command -v docker &>/dev/null; then
    alias dnp='docker network prune'
  fi

  if command -v exa &>/dev/null; then
    alias e='exa --git --color-scale --group-directories-first --icons'
  fi

  if command -v http &>/dev/null; then
    alias https='http --default-scheme=https'
  fi

  if command -v batman &>/dev/null; then
    alias man='batman'
  fi

  if command -v fuck &>/dev/null; then
    eval $(thefuck --alias)
  fi

  if command -v prettyping &>/dev/null; then
    alias pping='prettyping --nolegend'
  fi

  if command -v trash &>/dev/null; then
    alias rm='echo "Use trash command instead."; false'
    alias t='trash'
    alias tempty='trash-empty'
    alias tlist='trash-list'
    alias trestore='trash-restore'
    alias trm='trash-rm'
  fi

  if command -v tig &>/dev/null; then
    alias tia='tig --all'
    alias tib='tig blame -C'
    alias til='tig log'
    alias tis='tig status'
  fi

  if command -v xplr &>/dev/null; then
    alias xplr='xplr -c $XDG_CONFIG_HOME/xplr/init.lua'
  fi

  export ZSH_ALIAS_FINDER_AUTOMATIC=true
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/alias-finder/alias-finder.plugin.zsh

  export ZSH_TMUX_CONFIG="$XDG_CONFIG_HOME"/tmux/tmux.conf
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/tmux/tmux.plugin.zsh

  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/asdf/asdf.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/archlinux/archlinux.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/command-not-found/command-not-found.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/docker/docker.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/docker-compose/docker-compose.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/git/git.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/git-auto-fetch/git-auto-fetch.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/github/github.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/sudo/sudo.plugin.zsh
  z4h source "$Z4H"/ohmyzsh/ohmyzsh/plugins/yarn/yarn.plugin.zsh

  ###############################################################################

  eval "$(asdf exec direnv hook zsh)"
  direnv() { asdf exec direnv "$@"; }

  if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
  fi

  path=($(realpath "$XDG_CONFIG_HOME/../bin") $path)

  if [ -f "$XDG_CONFIG_HOME"/.zshrc.local ]; then
    "$XDG_CONFIG_HOME"/.zshrc.local
  fi
}
zshrc
unfunction zshrc
