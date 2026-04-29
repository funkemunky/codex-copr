#!/usr/bin/env bash

set -euo pipefail

TOPDIR="${TOPDIR:-$PWD/.rpmbuild}"
SOURCES_DIR="$TOPDIR/SOURCES"
SRPMS_DIR="$TOPDIR/SRPMS"
SPECS_DIR="$TOPDIR/SPECS"
WORK_DIR="$(mktemp -d)"
LATEST_URL="https://github.com/openai/codex/releases/latest/download/codex-x86_64-unknown-linux-musl.tar.gz"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$SOURCES_DIR" "$SRPMS_DIR" "$SPECS_DIR"

ARCHIVE="$WORK_DIR/codex-x86_64-unknown-linux-musl.tar.gz"
echo "Downloading latest Codex release tarball..."
curl -fL --retry 3 --retry-delay 2 -o "$ARCHIVE" "$LATEST_URL"

mkdir -p "$WORK_DIR/unpack"
tar -xzf "$ARCHIVE" -C "$WORK_DIR/unpack"

UPSTREAM_BINARY="$WORK_DIR/unpack/codex-x86_64-unknown-linux-musl"
if [[ ! -x "$UPSTREAM_BINARY" ]]; then
  echo "Expected upstream binary codex-x86_64-unknown-linux-musl, but it was not found." >&2
  exit 1
fi

VERSION="$("$UPSTREAM_BINARY" --version | awk '{print $2}')"
if [[ -z "$VERSION" ]]; then
  echo "Failed to determine Codex version from downloaded binary." >&2
  exit 1
fi

TAG="rust-v$VERSION"
SOURCE_TREE="$WORK_DIR/codex-$VERSION"
mkdir -p "$SOURCE_TREE"

install -pm 0755 "$UPSTREAM_BINARY" "$SOURCE_TREE/codex"

echo "Downloading LICENSE and README for $TAG..."
curl -fL --retry 3 --retry-delay 2 \
  -o "$SOURCE_TREE/LICENSE" \
  "https://raw.githubusercontent.com/openai/codex/$TAG/LICENSE"
curl -fL --retry 3 --retry-delay 2 \
  -o "$SOURCE_TREE/README.md" \
  "https://raw.githubusercontent.com/openai/codex/$TAG/README.md"

SOURCE_ARCHIVE="$SOURCES_DIR/codex-$VERSION-x86_64-unknown-linux-musl.tar.gz"
tar -C "$WORK_DIR" -czf "$SOURCE_ARCHIVE" "codex-$VERSION"

cp codex.spec "$SPECS_DIR/codex.spec"

echo "Building SRPM for version $VERSION..."
rpmbuild \
  --define "_topdir $TOPDIR" \
  --define "up_version $VERSION" \
  -bs "$SPECS_DIR/codex.spec"

echo
echo "SRPM written to:"
find "$SRPMS_DIR" -maxdepth 1 -type f -name "codex-$VERSION-*.src.rpm" -print
