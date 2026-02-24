#!/bin/bash
# Build Nox - the Novus package manager
# Requires the novus compiler binary in the current directory

set -e

if [ ! -f "./novus" ]; then
    echo "error: novus compiler not found"
    echo "download it from https://github.com/MJDaws0n/Novus"
    exit 1
fi

chmod +x ./novus

echo "building nox..."
./novus main.nov

if [ -f "./build/darwin_arm64/nox" ]; then
    echo ""
    echo "build successful!"
    echo "binary: ./build/darwin_arm64/nox"
    echo ""
    echo "to install globally:"
    echo "  ./install.sh"
else
    echo ""
    echo "build failed"
    exit 1
fi
