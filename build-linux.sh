#!/bin/bash
# Build Linux release binaries for Nox via Docker Buildx.
# Produces:
#   dist/nox-linux-amd64
#   dist/nox-linux-arm64

set -euo pipefail

NOVUS_VERSION="${NOVUS_VERSION:-V0.1.7}"

mkdir -p dist
rm -f dist/nox-linux-amd64 dist/nox-linux-arm64

build_one() {
  local platform="$1"
  local target="$2"
  local output_dir="$3"
  local outname="$4"
  local tmp_out
  local built_path

  tmp_out="$(mktemp -d)"
  echo "==> building ${outname} (${platform})"

  docker buildx build \
    --platform "$platform" \
    --progress=plain \
    -f Dockerfile.release \
    --build-arg NOVUS_VERSION="$NOVUS_VERSION" \
    --build-arg NOVUS_TARGET="$target" \
    --build-arg NOVUS_OUTPUT_DIR="$output_dir" \
    --build-arg NOVUS_BINARY_NAME="$outname" \
    --output "type=local,dest=${tmp_out}" \
    .

  built_path="${tmp_out}/${outname}"
  if [ ! -f "${built_path}" ] && [ -f "${tmp_out}/out/${outname}" ]; then
    built_path="${tmp_out}/out/${outname}"
  fi

  if [ ! -f "${built_path}" ]; then
    echo "error: expected ${tmp_out}/${outname}"
    ls -la "${tmp_out}" || true
    rm -rf "$tmp_out"
    return 1
  fi

  mv -f "${built_path}" "dist/${outname}"
  chmod +x "dist/${outname}"
  rm -rf "$tmp_out"
  echo "==> OK: dist/${outname}"
}

failures=0

if ! build_one linux/amd64 linux/amd64 linux_x86_64 nox-linux-amd64; then
  echo "warning: linux/amd64 build failed (likely Novus x86_64 codegen/toolchain issue)"
  failures=$((failures + 1))
fi

if ! build_one linux/arm64 linux/arm64 linux_arm64 nox-linux-arm64; then
  echo "warning: linux/arm64 build failed"
  failures=$((failures + 1))
fi

if [ ! -f "dist/nox-linux-amd64" ] && [ ! -f "dist/nox-linux-arm64" ]; then
  echo "error: no Linux binaries were produced"
  exit 1
fi

echo "done:"
ls -la dist | sed -n '1,120p'
