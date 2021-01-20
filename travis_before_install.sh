#!/bin/sh
# before_install script to use on Travis CI
# https://docs.travis-ci.com/user/installing-dependencies/#installing-projects-from-source

set -ex

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    sudo apt-get install -y libcairo2-dev;
fi

if [[ "$ZIG_VERSION" == "0.8.0-dev.1032+8098b3f84" ]]; then
    wget https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
else
    wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
fi

tar -xvf zig-linux-x86_64-${ZIG_VERSION}.tar.xz

# No need to alter the PATH. Just move zig to the existing HOME/bin directory.
mv ${PWD}/zig-linux-x86_64-${ZIG_VERSION}/zig ${HOME}/bin
