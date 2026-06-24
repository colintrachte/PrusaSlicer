#!/usr/bin/env bash
# PrusaSlicer Linux/macOS setup and build script.
# Full manual steps are documented in:
#   doc/How to build - Linux et al.md
#   doc/How to build - Mac OS.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_DIR="${1:-${SCRIPT_DIR}/../PrusaSlicer-deps}"
BUILD_DIR="${SCRIPT_DIR}/build"
CONFIG="${2:-RelWithDebInfo}"

step() { echo; echo "==> $*"; }
fail() { echo "ERROR: $*" >&2; exit 1; }

step "Checking prerequisites"

command -v cmake  >/dev/null 2>&1 || fail "cmake not found. Install via your package manager or https://cmake.org."
command -v git    >/dev/null 2>&1 || fail "git not found."
command -v ninja  >/dev/null 2>&1 || command -v make >/dev/null 2>&1 || fail "ninja or make not found."

echo "  cmake: $(cmake --version | head -1)"
echo "  git:   $(git --version)"

if [[ "$(uname)" == "Darwin" ]]; then
    command -v xcode-select >/dev/null 2>&1 || fail "Xcode command-line tools required. Run: xcode-select --install"
    echo "  platform: macOS $(sw_vers -productVersion)"
else
    echo "  platform: $(uname -sr)"
fi

step "Building dependencies (one-time, takes 20-60 minutes)"
echo "  Deps dir: ${DEPS_DIR}"

DEPS_BUILD="${DEPS_DIR}/build"
mkdir -p "${DEPS_BUILD}"

CMAKE_GENERATOR=""
if command -v ninja >/dev/null 2>&1; then
    CMAKE_GENERATOR="-G Ninja"
fi

cmake -S "${SCRIPT_DIR}/deps" -B "${DEPS_BUILD}" \
    -DCMAKE_BUILD_TYPE="${CONFIG}" \
    -DDEP_DEBUG=OFF \
    ${CMAKE_GENERATOR}

cmake --build "${DEPS_BUILD}" --parallel "$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"

DESTDIR="${DEPS_BUILD}/destdir/usr/local"

step "Configuring PrusaSlicer"
mkdir -p "${BUILD_DIR}"

cmake -S "${SCRIPT_DIR}" -B "${BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE="${CONFIG}" \
    -DCMAKE_PREFIX_PATH="${DESTDIR}" \
    -DSLIC3R_STATIC=ON \
    ${CMAKE_GENERATOR}

step "Building PrusaSlicer"
cmake --build "${BUILD_DIR}" --parallel "$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"

step "Build succeeded!"
echo "  Run the app with: ./run.sh"
echo "  Run tests with:   cd build && ctest -V"
