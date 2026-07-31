#!/bin/bash
# Package built release binaries into tarballs and checksums.

set -euo pipefail

VERSION="${VERSION:-$(sed -n '/fn get_version()/,/}/s/.*return "\([^"]*\)".*/\1/p' main.nov | head -n 1)}"

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

  local package_dir="dist/packages"
  local archive_name="${label}.tar.gz"
  local stage="${package_dir}/${label}"
  local archive="${package_dir}/${archive_name}"

  rm -rf "$stage"
  mkdir -p "$stage"
  cp "$bin_path" "$stage/nox"
  chmod +x "$stage/nox"
  tar -czf "$archive" -C "$stage" nox
  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$package_dir" && sha256sum "$archive_name" > "${archive_name}.sha256")
  else
    (cd "$package_dir" && shasum -a 256 "$archive_name" > "${archive_name}.sha256")
  fi
}

package_one dist/nox-darwin-arm64 "nox-v${VERSION}-darwin-arm64"
package_one dist/nox-linux-amd64 "nox-v${VERSION}-linux-amd64"
package_one dist/nox-linux-arm64 "nox-v${VERSION}-linux-arm64"

echo "packages:"
ls -la dist/packages
