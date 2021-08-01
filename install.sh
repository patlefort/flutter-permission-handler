#!/bin/bash

PREFIX="$1"

#install -dm755 "${PREFIX}/etc/netns-helper/ns"
install -dm755 "${PREFIX}/lib/systemd/system"
install -Dm644 "systemd/system"/* -t "${PREFIX}/lib/systemd/system"
install -dm755 "${PREFIX}/lib/netns-helper"
install -Dm755 'scripts/netns-helperctl' -t "${PREFIX}/lib/netns-helper/"
install -Dm755 'scripts/netns-dhclient-script-wrapper' -t "${PREFIX}/lib/netns-helper/"
install -Dm755 'scripts/netns-helper' -t "${PREFIX}/bin/"

if [[ ! -z "$PREFIX" && "$PREFIX" != '/' ]]; then
	override_prefix()
	{
		install -dm755 "${PREFIX}/lib/systemd/system/$1.d"
		local f="${PREFIX}/lib/systemd/system/$1.d/prefix.conf"
		echo "[Service]" > "$f"
		echo "Environment=PREFIX=$PREFIX" >> "$f"
	}
	
	override_dhclient_script()
	{
		install -dm755 "${PREFIX}/lib/systemd/system/$1.d"
		local f="${PREFIX}/lib/systemd/system/$1.d/prefix.conf"
		echo "[Service]" > "$f"
		echo "Environment=DHCLIENT_SCRIPT_WRAPPER=$PREFIX/lib/netns-helper/netns-dhclient-script-wrapper" >> "$f"
	}

	override_dhclient_script netns-helper-dhcp@.service
	override_dhclient_script netns-helper-dhcp6@.service
	override_prefix netns-helper-macvlan@.service
	override_prefix netns-helper-postup@.service
	override_prefix netns-helper@.service
fi

systemctl daemon-reload
