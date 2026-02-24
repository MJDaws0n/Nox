#!/bin/bash
# Install Nox to /usr/local/bin
# Run after build.sh

set -e

BINARY="./build/darwin_arm64/nox"

if [ ! -f "$BINARY" ]; then
    echo "error: nox binary not found at $BINARY"
    echo "run ./build.sh first"
    exit 1
fi

echo "installing nox to /usr/local/bin/nox..."
sudo cp "$BINARY" /usr/local/bin/nox
sudo chmod +x /usr/local/bin/nox

echo "done! nox is now available globally"
echo ""
echo "try: nox help"
