#!/usr/bin/env bash

set -euo pipefail

TOPDIR="${TOPDIR:-$PWD/.rpmbuild}"
SOURCES_DIR="$TOPDIR/SOURCES"
SRPMS_DIR="$TOPDIR/SRPMS"
SPECS_DIR="$TOPDIR/SPECS"
WORK_DIR="$(mktemp -d)"
LATEST_RELEASE_API="https://api.github.com/repos/openai/codex/releases/latest"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$SOURCES_DIR" "$SRPMS_DIR" "$SPECS_DIR"

echo "Resolving latest release tag..."
TAG="$(
  curl -fsSL --retry 3 --retry-delay 2 "$LATEST_RELEASE_API" \
    | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n1
)"
if [[ -z "$TAG" ]]; then
  echo "Failed to determine latest release tag from GitHub API." >&2
  exit 1
fi

VERSION="${TAG#rust-v}"
if [[ -z "$VERSION" || "$VERSION" == "$TAG" ]]; then
  echo "Unexpected tag format: $TAG (expected rust-v<version>)." >&2
  exit 1
fi

echo "Downloading LICENSE and README for $TAG..."
curl -fL --retry 3 --retry-delay 2 \
  -o "$WORK_DIR/LICENSE" \
  "https://raw.githubusercontent.com/openai/codex/$TAG/LICENSE"
curl -fL --retry 3 --retry-delay 2 \
  -o "$WORK_DIR/README.md" \
  "https://raw.githubusercontent.com/openai/codex/$TAG/README.md"

for ARCH in x86_64 aarch64; do
  ASSET_BASENAME="codex-$ARCH-unknown-linux-musl"
  LATEST_URL="https://github.com/openai/codex/releases/latest/download/$ASSET_BASENAME.tar.gz"
  ARCHIVE="$WORK_DIR/$ASSET_BASENAME.tar.gz"
  UNPACK_DIR="$WORK_DIR/unpack-$ARCH"
  SOURCE_TREE="$WORK_DIR/codex-$VERSION-$ARCH"

  echo "Downloading latest Codex release tarball for $ARCH..."
  curl -fL --retry 3 --retry-delay 2 -o "$ARCHIVE" "$LATEST_URL"

  mkdir -p "$UNPACK_DIR"
  tar -xzf "$ARCHIVE" -C "$UNPACK_DIR"

  UPSTREAM_BINARY="$UNPACK_DIR/$ASSET_BASENAME"
  if [[ ! -x "$UPSTREAM_BINARY" ]]; then
    echo "Expected upstream binary $ASSET_BASENAME, but it was not found." >&2
    exit 1
  fi

  mkdir -p "$SOURCE_TREE/codex-$VERSION"
  install -pm 0755 "$UPSTREAM_BINARY" "$SOURCE_TREE/codex-$VERSION/codex"
  install -pm 0644 "$WORK_DIR/LICENSE" "$SOURCE_TREE/codex-$VERSION/LICENSE"
  install -pm 0644 "$WORK_DIR/README.md" "$SOURCE_TREE/codex-$VERSION/README.md"

  SOURCE_ARCHIVE="$SOURCES_DIR/codex-$VERSION-$ARCH-unknown-linux-musl.tar.gz"
  tar -C "$SOURCE_TREE" -czf "$SOURCE_ARCHIVE" "codex-$VERSION"
done

sed "s/^%global up_version .*/%global up_version $VERSION/" \
  codex.spec > "$SPECS_DIR/codex.spec"

echo "Building SRPM for version $VERSION..."
rpmbuild \
  --define "_topdir $TOPDIR" \
  -bs "$SPECS_DIR/codex.spec"

echo
echo "SRPM written to:"
find "$SRPMS_DIR" -maxdepth 1 -type f -name "codex-$VERSION-*.src.rpm" -print
