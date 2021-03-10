#!/bin/sh

PREFIX=$1

install -dm755 "$PREFIX/etc/netns-helper/ns"
install -dm755 "$PREFIX/lib/systemd/system"
install -Dm644 "systemd/system"/* "$PREFIX/lib/systemd/system"
install -Dm755 "scripts/netns-helperctl" "$PREFIX/bin/netns-helperctl"

systemctl daemon-reload
