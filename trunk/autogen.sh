#!/bin/sh
# Run this to generate all the initial makefiles, etc.

mkdir -p m4
autoreconf -v --install || exit 1
./configure "$@"
