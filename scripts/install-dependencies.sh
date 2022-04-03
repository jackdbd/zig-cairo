#!/bin/bash
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

sudo apt-get install -y \
  libcairo2-dev \
  libpango1.0-dev \
  libpangocairo-1.0-0 \
  xvfb

# wget "https://ziglang.org/download/$ZIG_VERSION/zig-$ZIG_VERSION.tar.xz" \
#   --output-document "/tmp/zig-linux-$ZIG_VERSION.tar.xz" \
#   --show-progress

# tar -xvf "/tmp/zig-linux-$ZIG_VERSION.tar.xz" -C "$HOME"

# rm "/tmp/zig-linux-$ZIG_VERSION.tar.xz"

# mv "$HOME/zig-$ZIG_VERSION" "$ZIG_DIR"
