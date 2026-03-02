#!/bin/bash
# Build + smoke-test Linux release binaries for Nox using Docker Buildx (no bind mounts).
# Produces:
#   dist/nox-linux-amd64
#   dist/nox-linux-arm64

set -euo pipefail

NOVUS_VERSION="${NOVUS_VERSION:-V0.1.2}"

mkdir -p dist

build_one() {
  local platform="$1"   # linux/amd64 or linux/arm64
  local outname="$2"    # nox-linux-amd64 or nox-linux-arm64

  echo "==> building ${outname} (${platform})"

  tmp_out="$(mktemp -d)"
  docker buildx build \
    --platform "$platform" \
    --progress=quiet \
    -f Dockerfile.release \
    --build-arg NOVUS_VERSION="$NOVUS_VERSION" \
    --output "type=local,dest=${tmp_out}" \
    .

  if [ ! -f "${tmp_out}/${outname}" ]; then
    echo "error: expected ${tmp_out}/${outname}"
    ls -la "${tmp_out}" || true
    exit 1
  fi

  mv -f "${tmp_out}/${outname}" "dist/${outname}"
  chmod +x "dist/${outname}"
  rm -rf "$tmp_out"

  echo "==> OK: dist/${outname}"
}

build_one linux/amd64 nox-linux-amd64
build_one linux/arm64 nox-linux-arm64

echo "done:"
ls -la dist | sed -n '1,120p'
