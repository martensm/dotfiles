#!/usr/bin/env bash

set -eEuo pipefail

function _install() {
  sudo ln -vfs "$(dirname "$(readlink -f "$0")")"/etc/zsh/zshenv /etc/zsh/zshenv
  . /etc/zsh/zshenv

  if [ -v WSLENV ]; then
    local WSL="$XDG_CONFIG_HOME"/wsl
    sudo ln -vfs "$WSL"/etc/fonts/local.conf /etc/fonts/local.conf
    sudo ln -vfs "$WSL"/etc/wsl.conf /etc/wsl.conf
    sudo ln -vfs "$WSL"/bin/xclip /bin/xclip
    sudo ln -vfs "$WSL"/bin/xsel /bin/xsel

    sudo sed -i "s$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$" /usr/share/dbus-1/session.conf
  fi

  ln -vfs "$XDG_CONFIG_HOME"/gh/config.yml ~/.config/gh/config.yml
  ln -vfs "$XDG_CONFIG_HOME"/ssh/config ~/.ssh/config
  sudo ln -vfs "$XDG_CONFIG_HOME"/etc/pacman.conf /etc/pacman.conf
  sudo ln -vfs "$XDG_CONFIG_HOME"/etc/zsh/zshenv /etc/zsh/zshenv

  echo "Ranking mirrors..."
  curl -s "https://archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" |
    sed -e 's/^#Server/Server/' -e '/^#/d' |
    rankmirrors -n 5 - |
    sudo tee /etc/pacman.d/mirrorlist >/dev/null
  echo "Done"

  #shellcheck disable=SC2002
  cat "$XDG_CONFIG_HOME"/packages.txt | sudo pacman -S --needed --noconfirm -

  sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep "$(which bandwhich)"

  if ! type yay &>/dev/null; then
    local TMP
    TMP=$(mktemp -d -t yay-install-XXXXXXXXXX)
    git clone https://aur.archlinux.org/yay.git "$TMP"
    (cd "$TMP" && makepkg -sir --noconfirm)
    yes | yay -S yay-bin
    rm -rf "$TMP"
  fi

  yay -S --needed --noconfirm - <"$XDG_CONFIG_HOME"/packages-aur.txt

  export ASDF_DIR=$XDG_CACHE_HOME/asdf
  if [ ! -d "$ASDF_DIR" ]; then
    local release_tag
    release_tag=$(git ls-remote --exit-code --refs --sort='version:refname' \
      --tags https://github.com/asdf-vm/asdf.git '*.*.*' |
      tail --lines=1 |
      cut --delimiter='/' --fields=3)
    git clone https://github.com/asdf-vm/asdf.git --branch="$release_tag" "$ASDF_DIR"
  fi

  export ASDF_DATA_DIR=$XDG_DATA_HOME/asdf
  #shellcheck source=.cache/asdf/asdf.sh
  . "$ASDF_DIR"/asdf.sh

  exec 3<"$XDG_CONFIG_HOME"/asdf/tool_versions
  while read -r -u3 line; do
    local plugin
    plugin=$(echo "$line" | cut -d " " -f 1)
    if [ ! -d "$ASDF_DATA_DIR/plugins" ]; then
      asdf plugin add "$plugin"
    else
      asdf plugin update "$plugin"
    fi

    if [ "$plugin" = 'nodejs' ]; then
      "$ASDF_DATA_DIR"/plugins/nodejs/bin/import-release-team-keyring
    fi
  done
  asdf install
  asdf reshim

  export TMUX_PLUGIN_MANAGER_PATH=$XDG_CACHE_HOME/tmux/plugins
  if [ ! -f "$TMUX_PLUGIN_MANAGER_PATH"/tpm ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_MANAGER_PATH"
    "$TMUX_PLUGIN_MANAGER_PATH"/tpm/bin/install_plugins
  fi

  local ssh_key_path=$XDG_DATA_HOME/ssh
  mkdir -p "$ssh_key_path"

  if lpass status &>/dev/null; then
    local group="SSH Keys"
    local key
    for key in $(lpass ls "$group" --format="%an" | tail +1); do
      if [ ! -f "$ssh_key_path"/"$key" ]; then
        lpass show "$group/$key" --field="Private Key" >"$ssh_key_path"/"$key"
        chmod 600 "$ssh_key_path"/"$key"
      fi
      if [ ! -f "$ssh_key_path"/"$key".pub ]; then
        lpass show "$group/$key" --field="Public Key" >"$ssh_key_path"/"$key".pub
      fi
    done
  fi

  local nvim_cache="$XDG_CACHE_HOME"/nvim
  local venv="$nvim_cache"/venv
  mkdir -p "$nvim_cache"

  if [ ! -d "$venv" ]; then
    python -m venv "$venv"
  fi
  "$venv"/bin/pip install -U pip wheel
  "$venv"/bin/pip install -U pynvim PyYAML Send2Trash
}
_install
unset -f _install
