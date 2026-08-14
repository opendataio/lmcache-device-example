#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/LMCache-with-entry-point-support" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
LMCACHE_PATH="$(cd -- "$1" && pwd)"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required to build and validate this repository." >&2
  exit 1
fi

"${SCRIPT_DIR}/validate_local_install.sh" "${LMCACHE_PATH}" "$(
  cd "${REPO_ROOT}" &&
    uv build >/dev/null &&
    ls -t "${REPO_ROOT}"/dist/lmcache_device_example-*.whl | head -n 1
)"
