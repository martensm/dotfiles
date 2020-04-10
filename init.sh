#!/usr/bin/env bash

set -eEuo pipefail

function _init() {
	local user=${DOTFILES_USERNAME:-'matt'}

	pacman-key --init
	pacman-key --populate

	pacman -Syu git zsh --needed --noconfirm

	useradd -m -G wheel -s "$(command -v zsh)" "${user}"

	sed /etc/sudoers -i -Ee 's/^\s*#\s*%wheel\s*ALL=\(ALL\)\s*ALL$/%wheel\tALL=(ALL)\tALL/'

	echo "Password for root"
	passwd

	echo "Password for ${user}"
	passwd "${user}"

	pacman -S base-devel --needed

	if command -v Arch.exe &>/dev/null; then
		Arch.exe config --default-user "${user}"
	fi
}
_init
unset _init
