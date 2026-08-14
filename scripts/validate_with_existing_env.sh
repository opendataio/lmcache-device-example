#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 /path/to/python /path/to/LMCache-with-entry-point-support" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
PYTHON="$(cd -- "$(dirname -- "$1")" && pwd)/$(basename -- "$1")"
LMCACHE_PATH="$(cd -- "$2" && pwd)"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required to install the validation wheel." >&2
  exit 1
fi

WHEEL_PATH="$(
  cd "${REPO_ROOT}" &&
    uv build >/dev/null &&
    ls -t "${REPO_ROOT}"/dist/lmcache_device_example-*.whl | head -n 1
)"

uv pip install --python "${PYTHON}" "${WHEEL_PATH}" >/dev/null

(
  cd "${LMCACHE_PATH}"
  LMCACHE_DEVICE_EXAMPLE_ENABLE=1 \
  DEVICE_TYPE=example_cpu \
    "${PYTHON}" -m lmcache_device_example.validate
)
