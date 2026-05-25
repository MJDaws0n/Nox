#!/bin/bash
# Install macOS arm64 Nox binary to /usr/local/bin.

set -e

BINARY="./dist/nox-darwin-arm64"

if [ ! -f "$BINARY" ]; then
    echo "error: nox binary not found at $BINARY"
    echo "run ./build.sh first"
    exit 1
fi

echo "installing nox to /usr/local/bin/nox..."
sudo cp "$BINARY" /usr/local/bin/nox
sudo chmod +x /usr/local/bin/nox
sudo xattr -d com.apple.quarantine /usr/local/bin/nox 2>/dev/null || true

echo "done! nox is now available globally"
echo ""
echo "try: nox help"
