#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 /path/to/LMCache-with-entry-point-support [/path/to/wheel]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
LMCACHE_PATH="$(cd -- "$1" && pwd)"
WHEEL_PATH="${2:-}"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required to build and validate this repository." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required because LMCache uses setuptools-scm during install." >&2
  exit 1
fi

if [[ -z "${WHEEL_PATH}" ]]; then
  WHEEL_PATH="$(
    cd "${REPO_ROOT}" &&
      ls -t "${REPO_ROOT}"/dist/lmcache_device_example-*.whl | head -n 1
  )"
fi

if [[ ! -f "${WHEEL_PATH}" ]]; then
  echo "Wheel not found: ${WHEEL_PATH}" >&2
  exit 1
fi

WORK_DIR="${TMPDIR:-/tmp}/lmcache-device-example-validate"
rm -rf "${WORK_DIR}"
uv venv "${WORK_DIR}/.venv" --python 3.12 >/dev/null

PYTHON="${WORK_DIR}/.venv/bin/python"
VALIDATE_BIN="${WORK_DIR}/.venv/bin/lmcache-device-example-validate"

uv pip install --python "${PYTHON}" torch >/dev/null
uv pip install --python "${PYTHON}" Cython >/dev/null
NO_NATIVE_EXT=1 uv pip install \
  --python "${PYTHON}" \
  -e "${LMCACHE_PATH}" \
  --no-build-isolation >/dev/null
uv pip install --python "${PYTHON}" "${WHEEL_PATH}" >/dev/null

LMCACHE_DEVICE_EXAMPLE_ENABLE=1 \
DEVICE_TYPE=example_cpu \
  "${VALIDATE_BIN}"

echo "Validated wheel install in ${WORK_DIR}/.venv"
