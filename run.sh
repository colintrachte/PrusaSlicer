#!/usr/bin/env bash
# Launches the built PrusaSlicer binary.
# Usage: ./run.sh [slicer|console|viewer] [build-dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-slicer}"
BUILD_DIR="${2:-${SCRIPT_DIR}/build}"

fail() { echo "ERROR: $*" >&2; exit 1; }

case "${MODE}" in
    slicer)  BINARY="prusa-slicer" ;;
    console) BINARY="prusa-slicer-console" ;;
    viewer)  BINARY="prusa-gcodeviewer" ;;
    *) fail "Unknown mode '${MODE}'. Use: slicer, console, or viewer." ;;
esac

# Search common build output locations
FOUND=""
for CANDIDATE in \
    "${BUILD_DIR}/src/${BINARY}" \
    "${BUILD_DIR}/src/PrusaSlicer_app_gui" \
    "${BUILD_DIR}/${BINARY}"; do
    if [[ -x "${CANDIDATE}" ]]; then
        FOUND="${CANDIDATE}"
        break
    fi
done

[[ -n "${FOUND}" ]] || fail "${BINARY} not found in ${BUILD_DIR}. Run ./setup.sh first."

echo "Launching: ${FOUND}"
exec "${FOUND}" "$@"
