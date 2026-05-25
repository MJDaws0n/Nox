#!/bin/bash
# Package built release binaries into tarballs and checksums.

set -euo pipefail

VERSION="${VERSION:-$(./build/darwin_arm64/nox version 2>/dev/null | tail -n 1 | sed 's/^nox v//')}"

if [ -z "${VERSION}" ]; then
  echo "error: could not determine version"
  exit 1
fi

mkdir -p dist/packages
rm -rf dist/packages/*

package_one() {
  local bin_path="$1"
  local label="$2"

  if [ ! -f "$bin_path" ]; then
    return
  fi

  local stage="dist/packages/${label}"
  local archive="dist/packages/${label}.tar.gz"

  rm -rf "$stage"
  mkdir -p "$stage"
  cp "$bin_path" "$stage/nox"
  chmod +x "$stage/nox"
  tar -czf "$archive" -C "$stage" nox
  shasum -a 256 "$archive" > "${archive}.sha256"
}

package_one dist/nox-darwin-arm64 "nox-v${VERSION}-darwin-arm64"
package_one dist/nox-linux-amd64 "nox-v${VERSION}-linux-amd64"
package_one dist/nox-linux-arm64 "nox-v${VERSION}-linux-arm64"

echo "packages:"
ls -la dist/packages
