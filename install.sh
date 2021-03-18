#!/bin/sh

PREFIX=$1

install -dm755 "$PREFIX/etc/netns-helper/ns"
install -dm755 "$PREFIX/lib/systemd/system"
install -Dm644 "systemd/system"/* -t "$PREFIX/lib/systemd/system"
install -Dm755 "scripts"/* -t "$PREFIX/bin"

systemctl daemon-reload
