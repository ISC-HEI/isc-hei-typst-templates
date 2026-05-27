#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)"
source "$SCRIPT_DIR/test-helpers.sh"

PACKAGE_VERSION="$(typst_template_version "poster")"

echo "Removing tmp/isc-hei-poster if it exists..."
if rm -r tmp/isc-hei-poster 2>/dev/null; then
	echo "Removed tmp/isc-hei-poster successfully or it did not exist."
else
	echo "Failed to remove tmp/isc-hei-poster." >&2
fi

echo "Creating tmp directory if it does not exist..."
if mkdir -p tmp; then
	echo "tmp directory is ready."
else
	echo "Failed to create tmp directory." >&2
	exit 1
fi

cd tmp
typst init "@preview/isc-hei-poster:${PACKAGE_VERSION}"
cd isc-hei-poster
echo "Compiling poster..."
typst compile poster.typ
echo "Compiling done"
cd ..
cd ..
