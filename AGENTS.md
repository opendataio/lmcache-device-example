# AGENTS.md

Guidance for coding agents working in this repository.

## Purpose

This repository is a **packaging and discovery example** for an out-of-tree
LMCache device backend distributed as a wheel.

## Guardrails

- Keep the example backend **disabled by default**. It should only become
  selectable when `LMCACHE_DEVICE_EXAMPLE_ENABLE=1` is set.
- Keep `device_type="example_cpu"` unless the task explicitly needs a new
  compatibility target. This repository is meant to validate LMCache's
  third-party device registration flow without colliding with built-in
  backends.
- The example intentionally reuses LMCache's CPU building blocks. It is a
  discovery/integration fixture, not a production accelerator backend.

## Validation

- Build the wheel with `uv build`.
- Validate against an LMCache checkout that already includes
  `lmcache.v1.device_specs` entry-point discovery support.
- Prefer `scripts/build_and_validate_local.sh /path/to/LMCache` for the full
  local verification pass. The script installs LMCache with
  `NO_NATIVE_EXT=1` so packaging validation does not depend on CUDA toolchains.
- On this macOS validation path, install `Cython` into the temporary virtual
  environment before the LMCache editable install. LMCache currently depends on
  `nvtx`, and `uv pip` may need `Cython` preinstalled in order to build that
  dependency successfully.
- The most reliable smoke test is still an **existing, working LMCache Python
  environment**. Install the built wheel into that interpreter and run
  `scripts/validate_with_existing_env.sh /path/to/python /path/to/LMCache`.
  A fresh source-only LMCache install may still fail to import if its native
  module set is incomplete for the host.
