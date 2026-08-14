#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <lmcache_repo_url> <lmcache_ref>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
LMCACHE_REPO_URL="$1"
LMCACHE_REF="$2"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required for CI validation." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required for CI validation." >&2
  exit 1
fi

WHEEL_PATH="$(
  cd "${REPO_ROOT}" &&
    ls -t "${REPO_ROOT}"/dist/lmcache_device_example-*.whl | head -n 1
)"

if [[ ! -f "${WHEEL_PATH}" ]]; then
  echo "Wheel not found: ${WHEEL_PATH}" >&2
  exit 1
fi

WORK_DIR="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/lmcache-device-example-ci"
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

git clone --depth 1 --branch "${LMCACHE_REF}" "${LMCACHE_REPO_URL}" \
  "${WORK_DIR}/LMCache" >/dev/null

"${SCRIPT_DIR}/validate_local_install.sh" "${WORK_DIR}/LMCache" "${WHEEL_PATH}"
