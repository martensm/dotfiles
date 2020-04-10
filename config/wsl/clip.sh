#!/bin/sh

# basic xclip/xsel emulation for WSL

if command -v powershell.exe >/dev/null 2>&1; then
	pwsh="powershell.exe -NoProfile -NoLogo -NonInteractive"
else
	exit 1
fi

for i in "$@"; do
	case "$i" in
	-o | -out | --output)
		$pwsh -command Get-Clipboard | sed 's/\r$//' | head -c -1
		exit 0
		;;
	-i | -in | --input)
		_restore_umask=$(umask)
		_try=0
		while :; do
			_try=$((_try + 1))
			umask 0077
			_tmp_dir=/tmp/$(basename "$0").$$.$(date +%s).$_try
			trap 'rm -fr $_tmp_dir; umask $_restore_umask' EXIT
			mkdir "$_tmp_dir" 2>/dev/null && break
		done
		unset _try

		_distro="$(lsb_release -is)"

		cat >"$_tmp_dir"/clipboard
		$pwsh "Get-Content //wsl$/$_distro$_tmp_dir/clipboard | Set-Clipboard"
		rm -fr $_tmp_dir

		umask "$_restore_umask"
		unset _restore_umask _tmp_dir _distro
		exit 0
		;;
	esac
done
