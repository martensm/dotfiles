#!/usr/bin/env bash

set -eEuo pipefail

function _install() {
	XDG_CONFIG_HOME=$(dirname "$(readlink -f "$0")")/config
	export XDG_CONFIG_HOME
	export XDG_CACHE_HOME="$XDG_CONFIG_HOME"/.cache
	export XDG_DATA_HOME="$XDG_CONFIG_HOME"/.data

	if [ -v WSLENV ]; then
		cat <<-EOF >"$XDG_DATA_HOME"/environment.sh
			#!/usr/bin/env sh

			export XDG_CONFIG_HOME=$XDG_CONFIG_HOME
			export XDG_CACHE_HOME=$XDG_CACHE_HOME
			export XDG_DATA_HOME=$XDG_DATA_HOME

			export CHROME_USER_DATA_DIR=$XDG_DATA_HOME/chromium
			export DOCKER_CONFIG=$XDG_CACHE_HOME/docker
			export GNUPGHOME=$XDG_CACHE_HOME/gnupg
			export ICEAUTHORITY=$XDG_CACHE_HOME/ICEauthority
			export PIPX_BIN_DIR=$XDG_DATA_HOME/pipx
			export PULSE_COOKIE=$XDG_CACHE_HOME/pulse-cookie
			export PYWAL_CACHE_DIR=$XDG_CACHE_HOME/pywal
			export RUSTUP_HOME=$XDG_DATA_HOME/rustup
			export XAUTHORITY=$XDG_DATA_HOME/Xauthority
			export ZDOTDIR=$XDG_CONFIG_HOME/zsh

			export BROWSER=${BROWSER:-/usr/bin/chromium}
			export EDITOR=${EDITOR:-/usr/bin/nvim}
		EOF
		chmod u+x "$XDG_DATA_HOME"/environment.sh

		sudo ln -vfs "$XDG_DATA_HOME"/environment.sh /etc/zsh/zshenv
		sudo ln -vfs "$XDG_CONFIG_HOME"/wsl/etc/wsl.conf /etc/wsl.conf

		sudo sed -i \
			"s$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$" \
			/usr/share/dbus-1/session.conf
	else
		cat <<-EOF >"$XDG_DATA_HOME"/.pam_environment
			XDG_CONFIG_HOME DEFAULT=$XDG_CONFIG_HOME
			XDG_CACHE_HOME DEFAULT=$XDG_CACHE_HOME
			XDG_DATA_HOME DEFAULT=$XDG_DATA_HOME

			CHROME_USER_DATA_DIR DEFAULT=$XDG_DATA_HOME/chromium
			DOCKER_CONFIG DEFAULT=$XDG_CACHE_HOME/docker
			GNUPGHOME DEFAULT=$XDG_CACHE_HOME/gnupg
			ICEAUTHORITY DEFAULT=$XDG_CACHE_HOME/ICEauthority
			PIPX_BIN_DIR DEFAULT=$XDG_DATA_HOME/pipx
			PULSE_COOKIE DEFAULT=$XDG_CACHE_HOME/pulse-cookie
			PYWAL_CACHE_DIR DEFAULT=$XDG_CACHE_HOME/pywal
			RUSTUP_HOME DEFAULT=$XDG_DATA_HOME/rustup
			XAUTHORITY DEFAULT=$XDG_DATA_HOME/Xauthority
			ZDOTDIR DEFAULT=$XDG_CONFIG_HOME/zsh

			BROWSER DEFAULT=${BROWSER:-/usr/bin/chromium}
			EDITOR DEFAULT=${EDITOR:-/usr/bin/nvim}
		EOF
		ln -vfs "$XDG_DATA_HOME"/.pam_environment ~/.pam_environment
		ln -vfs "$XDG_CONFIG_HOME"/imwheel/config ~/.imwheelrc

		localectl set-locale LANG=en_US.UTF-8
	fi

	mkdir -p ~/.ssh &&
		ln -vfs "$XDG_CONFIG_HOME"/ssh/config ~/.ssh/config
	ln -vfs "$XDG_CONFIG_HOME"/X11/xinitrc ~/.xinitrc
	sudo ln -vfs "$XDG_CONFIG_HOME"/etc/fwupd/uefi_capsule.conf \
		/etc/fwupd/uefi_capsule.conf
	sudo ln -vfs "$XDG_CONFIG_HOME"/etc/ufw/ufw.conf /etc/ufw/ufw.conf
	sudo ln -vfs "$XDG_CONFIG_HOME"/etc/ufw/user.rules /etc/ufw/user.rules
	sudo ln -vfs "$XDG_CONFIG_HOME"/etc/ufw/user6.rules /etc/ufw/user6.rules
	sudo ln -vfs "$XDG_CONFIG_HOME"/etc/X11/Xwrapper.config \
		/etc/X11/Xwrapper.config
	sudo ln -vfs "$XDG_CONFIG_HOME"/etc/locale.gen /etc/locale.gen
	sudo ln -vfs "$XDG_CONFIG_HOME"/etc/pacman.conf /etc/pacman.conf
	sudo ln -vfs "$XDG_CONFIG_HOME"/etc/updatedb.conf /etc/updatedb.conf

	sudo pacman -Syu --noconfirm
	#shellcheck disable=SC2002
	cat "$XDG_CONFIG_HOME"/packages.txt | sudo pacman -S --needed --noconfirm -

	if [ -v WSLENV ]; then
		local WSL="$XDG_CONFIG_HOME"/wsl
		sudo ln -vfs "$WSL"/bin/xclip /bin/xclip
		sudo ln -vfs "$WSL"/bin/xsel /bin/xsel
	else
		systemctl --user --now enable spotifyd
		sudo gpasswd -a "$USER" docker
		sudo systemctl enable --now \
			ananicy-cpp.service \
			docker.socket \
			nohang-desktop.service \
			ntpd.service \
			systemd-resolved \
			ufw
		sudo systemctl enable NetworkManager plocate-updatedb.timer
	fi

	rustup default stable
	rustup install nightly

	sudo setcap \
		cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep \
		"$(which bandwhich)"

	sudo mkdir -p /usr/share/fonts
	if ! [ "$(fc-list | grep -c 'Fission')" -ge 1 ]; then
		podman run -it --rm -v "$XDG_CONFIG_HOME"/iosevka:/build \
			avivace/iosevka-build ttf::fission
		sudo rm -rf "$XDG_CONFIG_HOME"/iosevka/dist/fission/ttf-unhinted/
		sudo cp -r "$XDG_CONFIG_HOME"/iosevka/dist/* /usr/share/fonts/
		sudo rm -rf "$XDG_CONFIG_HOME"/iosevka/dist/
		fc-cache -f >/dev/null
	fi
	if ! [ "$(fc-list | grep -c 'IcoMoon-Ultimate')" -ge 1 ]; then
		sudo ln -vfs "$XDG_CONFIG_HOME"/fonts/IcoMoon-Ultimate.ttf \
			/usr/share/fonts/IcoMoon-Ultimate.ttf
		fc-cache -f >/dev/null
	fi

	if ! type paru &>/dev/null; then
		local TMP
		TMP=$(mktemp -d -t paru-install-XXXXXXXXXX)
		git clone https://aur.archlinux.org/paru-bin.git "$TMP"
		(cd "$TMP" && makepkg -sir --noconfirm)
		rm -rf "$TMP"
	fi

	paru -S --needed --noconfirm - <"$XDG_CONFIG_HOME"/packages-aur.txt

	export ASDF_DIR=/opt/asdf-vm
	export ASDF_DATA_DIR=$XDG_DATA_HOME/asdf
	#shellcheck source=config/.cache/asdf/asdf.sh
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
	done
	asdf install
	asdf reshim

	export TMUX_PLUGIN_MANAGER_PATH=$XDG_CACHE_HOME/tmux/plugins
	if [ ! -f "$TMUX_PLUGIN_MANAGER_PATH"/bin/install_plugins ]; then
		git clone --depth 1 https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_MANAGER_PATH"
		"$TMUX_PLUGIN_MANAGER_PATH"/bin/install_plugins
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
		done
	fi
}
_install
unset -f _install
