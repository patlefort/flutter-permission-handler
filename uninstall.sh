#!/bin/sh

PREFIX=$1

rm -f "$PREFIX/lib/systemd/system/netns-helper"/*
rm -f "$PREFIX/bin/netns-helperctl"
rm -f "$PREFIX/bin/netns-dhclient-script-wrapper"

systemctl daemon-reload
