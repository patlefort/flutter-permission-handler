#!/bin/sh

DESTDIR=${DESTDIR:-/}
PREFIX="${PREFIX:-/usr/local}"

installdir="$DESTDIR/$PREFIX"

install -dm755 "${DESTDIR}/etc/netns-helper/ns"
install -dm755 "${installdir}/lib/systemd/system"
install -Dm644 'systemd/system/netns-helper@.target' -t "${installdir}/lib/systemd/system"
install -dm755 "${installdir}/lib/netns-helper"
install -Dm755 'scripts/netns-helperctl' -t "${installdir}/lib/netns-helper/"
install -Dm755 'scripts/netns-dhclient-script-wrapper' -t "${installdir}/lib/netns-helper/"
install -Dm755 'scripts/netns-helper' -t "${installdir}/bin/"
install -Dm644 'scripts/bash-completion' "${installdir}/share/bash-completion/completions/netns-helper"

for unit in 'systemd/system'/*.in; do
	unitfile="${installdir}/lib/${unit%.*}"
	install -Dm644 "$unit" "$unitfile"
	sed -i "s|@PREFIX@|${PREFIX}|" "$unitfile"
done
