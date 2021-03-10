#!/bin/sh

PREFIX=$1

systemctl disable --now "netns_helper-dhcp@"
systemctl disable --now "netns_helper-macvlan@"
systemctl disable --now "netns_helper@"

rm -f "$PREFIX/lib/systemd/system/netns_helper"/*
rm -f "$PREFIX/bin/netns_helperctl"

systemctl daemon-reload
