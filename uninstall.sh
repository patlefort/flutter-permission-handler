#!/bin/sh

PREFIX=$1

rm -f "$PREFIX/lib/systemd/system/netns-helper"/*
rm -f "$PREFIX/bin/netns-helperctl"

systemctl daemon-reload
