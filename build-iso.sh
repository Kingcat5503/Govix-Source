#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"

# Default paths (relative to repository root)
RELENG_DIR="${SCRIPT_DIR}/releng"
OUTPUT_DIR="${SCRIPT_DIR}/builds"
WORKDIR="${HOME}/.cache/archiso-workdir"
MKARCHISO_OPTS=("-v")

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

Options:
	-r, --releng DIR       Path to releng directory (default: ${RELENG_DIR})
	-o, --output DIR       Output directory for generated ISO (default: ${OUTPUT_DIR})
	-w, --workdir DIR      Work directory for mkarchiso (default: ${WORKDIR})
			--keep-workdir     Don't remove workdir after build
	-h, --help             Show this help and exit

This script wraps mkarchiso to build an ISO from a releng tree.
It will create the output directory if missing and run mkarchiso with
some reasonable defaults. It requires 'mkarchiso' to be installed.
EOF
}

KEEP_WORKDIR=false

while [[ ${#} -gt 0 ]]; do
	case "$1" in
		-r|--releng)
			RELENG_DIR="$(readlink -f "$2")"
			shift 2
			;;
		-o|--output)
			OUTPUT_DIR="$(readlink -f "$2")"
			shift 2
			;;
		-w|--workdir)
			WORKDIR="$(readlink -f "$2")"
			shift 2
			;;
		--keep-workdir)
			KEEP_WORKDIR=true
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1" >&2
			usage
			exit 2
			;;
	esac
done

# Minimal checks
if [[ ! -d "${RELENG_DIR}" ]]; then
	echo "releng directory not found: ${RELENG_DIR}" >&2
	exit 1
fi

mkdir -p "${OUTPUT_DIR}"
mkdir -p "${WORKDIR}"

if ! command -v mkarchiso >/dev/null 2>&1; then
	echo "mkarchiso not found. Install archiso package (pacman -S archiso) and try again." >&2
	exit 2
fi

echo "Building ISO from: ${RELENG_DIR}"
echo "Output directory: ${OUTPUT_DIR}"
echo "Work dir: ${WORKDIR}"

BUILD_CMD=(sudo mkarchiso "${MKARCHISO_OPTS[@]}" -r -w "${WORKDIR}" -o "${OUTPUT_DIR}" "${RELENG_DIR}")

echo "Running: ${BUILD_CMD[*]}"

"${BUILD_CMD[@]}"

if [[ "${KEEP_WORKDIR}" != true ]]; then
	echo "Cleaning workdir: ${WORKDIR}"
	sudo rm -rf "${WORKDIR}" || true
else
	echo "Keeping workdir: ${WORKDIR}"
fi

echo "+=================================+"
echo "|         Build finished.         |"
echo "+=================================+"