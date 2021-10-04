#!/bin/bash

set -exu

tar -C /tmp -Jxf /tmp/ghc.tar.xz
cd /tmp/ghc-8.10.7*
./configure --disable-ld-override --prefix=/opt/ghc/8.10.7
make install

exec "$@"
