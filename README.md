# lmcache-device-example

`lmcache-device-example` is a minimal **out-of-tree LMCache device backend**
distributed as a Python wheel.

It exists to verify that LMCache can discover a third-party `DeviceSpec`
through the `lmcache.v1.device_specs` entry-point group after the wheel is
installed into the same environment as LMCache.

## What this example does

- registers `device_type="example_cpu"` from outside the LMCache repository
- reuses LMCache's CPU cache context, IPC wrapper, and baseline ops
- stays **disabled by default**
- becomes discoverable only when `LMCACHE_DEVICE_EXAMPLE_ENABLE=1`

This makes it safe to install for packaging tests without changing normal
LMCache behavior on hosts that do not opt in to the example backend.

## Why this is a packaging test, not a full vLLM e2e test

This example intentionally binds to `torch.cpu` so it can run on any machine.
That is enough to validate:

- wheel packaging
- entry-point discovery
- LMCache backend registration
- `DEVICE_TYPE=example_cpu` explicit selection

It is **not** a real accelerator backend, so it should not be used as the
basis for a vLLM hardware e2e test. For a real device package, the next stage
would be to install the vendor wheel into a true `<device> + LMCache + vLLM`
environment and verify real tensors flow through that backend.

## Build the wheel

```bash
uv build
```

The resulting wheel is written under `dist/`.

## Validate in an existing LMCache environment

This is the recommended smoke test, because it matches the real deployment
shape: install the wheel into a Python environment where LMCache already works.

```bash
uv build
scripts/validate_with_existing_env.sh \
  /path/to/python \
  /path/to/LMCache
```

The script will:

1. install the built wheel into the supplied interpreter
2. switch into the supplied LMCache checkout
3. set `LMCACHE_DEVICE_EXAMPLE_ENABLE=1` and `DEVICE_TYPE=example_cpu`
4. run `lmcache-device-example-validate`

## Validate against a local LMCache checkout with a fresh temporary venv

Use an LMCache checkout that already contains third-party device entry-point
discovery support.

```bash
scripts/build_and_validate_local.sh /path/to/LMCache
```

The script will:

1. build this wheel
2. create a fresh Python 3.12 virtual environment
3. install `torch`
4. install LMCache from the supplied checkout with `NO_NATIVE_EXT=1`
5. install the built wheel
6. run `lmcache-device-example-validate`

This path is convenient for packaging checks, but it assumes the supplied
LMCache install path can import all required native modules on that host.

## Continuous Integration

This repository includes a GitHub Actions workflow that:

1. builds the wheel
2. clones a target LMCache repository and ref
3. installs LMCache into a fresh Python 3.12 environment
4. installs this wheel
5. runs `lmcache-device-example-validate`

The workflow currently defaults to validating against:

- repository: `https://github.com/maobaolong/LMCache.git`
- ref: `mbl/device-spec-entrypoint-discovery`

That default should be updated once entry-point discovery lands on a stable
LMCache branch.

## Manual validation

After installing LMCache and this wheel into the same environment:

```bash
export LMCACHE_DEVICE_EXAMPLE_ENABLE=1
export DEVICE_TYPE=example_cpu
lmcache-device-example-validate
```

Successful validation confirms that LMCache discovered the out-of-tree backend
and bound the example `DeviceSpec` and `DeviceOps`.
