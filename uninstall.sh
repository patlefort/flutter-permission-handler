#!/usr/bin/env sh

PREFIX="${PREFIX:-/usr/local}"

rm -rvf "$PREFIX/lib/systemd/system/netns-helper"*
rm -rvf "$PREFIX/lib/netns-helper"
rm -vf "$PREFIX/bin/netns-helper"
