#!/bin/sh

PREFIX=$1

systemctl disable --now "netns-helper-dhcp@"
systemctl disable --now "netns-helper-macvlan@"
systemctl disable --now "netns-helper@"

rm -f "$PREFIX/lib/systemd/system/netns-helper"/*
rm -f "$PREFIX/bin/netns-helperctl"

systemctl daemon-reload
