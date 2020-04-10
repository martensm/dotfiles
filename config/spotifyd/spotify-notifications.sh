#!/usr/bin/env sh

if [ "$PLAYER_EVENT" = "start" ] || [ "$PLAYER_EVENT" = "change" ]; then
	track_name=$(playerctl metadata title)
	artist_and_album_name=$(playerctl metadata --format "by {{ artist }}\non {{ album }}")

	tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}"/spotifyd.XXXXXXXX)
	curl "$(playerctl metadata mpris:artUrl)" >"$tmp_dir"/album_art

	notify-send -u low -i "$tmp_dir/album_art" "$track_name" "$artist_and_album_name"

	rm -r "$tmp_dir"
fi
