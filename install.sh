#!/bin/sh

PREFIX=$1

install -dm755 "$PREFIX/etc/netns_helper/ns"
install -dm755 "$PREFIX/lib/systemd/system"
install -Dm644 "systemd/system"/* "$PREFIX/lib/systemd/system"
install -Dm755 "scripts/netns_helperctl" "$PREFIX/bin/netns_helperctl"

systemctl daemon-reload
