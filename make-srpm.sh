#!/usr/bin/env bash

set -euo pipefail

TOPDIR="${TOPDIR:-$PWD/.rpmbuild}"
SRPMS_DIR="$TOPDIR/SRPMS"

mkdir -p "$SRPMS_DIR"

echo "Building SRPM using rpkg..."
rpkg srpm --outdir "$SRPMS_DIR"

echo
echo "SRPM written to:"
find "$SRPMS_DIR" -maxdepth 1 -type f -name "*.src.rpm" -print
