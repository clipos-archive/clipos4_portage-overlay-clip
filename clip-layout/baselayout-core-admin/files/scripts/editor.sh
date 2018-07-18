#!/bin/sh
export LC_ALL=fr_FR
export LANG=fr_FR
export TERM="xterm"

exec /bin/nano -w "${@}"
