#!/bin/bash
# Build macOS arm64 release binary for Nox.

set -e

if ! command -v novus >/dev/null 2>&1; then
    echo "error: novus compiler not found in PATH"
    echo "install it from https://github.com/MJDaws0n/Novus"
    exit 1
fi

mkdir -p dist

echo "building nox for darwin/arm64..."
novus --target=darwin/arm64 main.nov

if [ -f "./build/darwin_arm64/nox" ]; then
    cp "./build/darwin_arm64/nox" "./dist/nox-darwin-arm64"
    chmod +x "./dist/nox-darwin-arm64"
    echo ""
    echo "build successful!"
    echo "binary: ./dist/nox-darwin-arm64"
    echo ""
    echo "to install globally on macOS:"
    echo "  ./install.sh"
else
    echo ""
    echo "build failed"
    exit 1
fi
