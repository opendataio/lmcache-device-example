# SPDX-License-Identifier: Apache-2.0
"""Validation helpers for the example LMCache device wheel."""

# Future
from __future__ import annotations

# Standard
from importlib import metadata as importlib_metadata
import os

_DEVICE_TYPE = "example_cpu"
_ENABLE_ENV_VAR = "LMCACHE_DEVICE_EXAMPLE_ENABLE"


def _entry_points_for_group(group: str) -> list[object]:
    """Return entry points from *group* across supported Python APIs."""
    entry_points = importlib_metadata.entry_points()
    select = getattr(entry_points, "select", None)
    if callable(select):
        return list(select(group=group))

    legacy_get = getattr(entry_points, "get", None)
    if callable(legacy_get):
        return list(legacy_get(group, ()))

    return []


def validate_install() -> dict[str, str]:
    """Validate that LMCache discovered the installed example wheel.

    Returns:
        A small summary describing the detected backend state.

    Raises:
        RuntimeError: If the required opt-in environment variables are absent.
        AssertionError: If LMCache did not discover or bind the backend.
    """
    enabled = os.environ.get(_ENABLE_ENV_VAR)
    device_type = os.environ.get("DEVICE_TYPE")
    if enabled != "1" or device_type != _DEVICE_TYPE:
        raise RuntimeError(
            "Set LMCACHE_DEVICE_EXAMPLE_ENABLE=1 and DEVICE_TYPE=example_cpu "
            "before running lmcache-device-example-validate."
        )

    # Third Party
    import torch

    # First Party
    import lmcache
    from lmcache.v1.platform import (
        current_device_spec,
        get_device_spec,
        get_torch_device,
        resolve_device_ops,
        resolve_kv_wrapper_factory,
    )

    entry_points = _entry_points_for_group("lmcache.v1.device_specs")
    assert any(
        getattr(entry_point, "name", None) == _DEVICE_TYPE
        for entry_point in entry_points
    ), "example entry point was not registered"

    spec = get_device_spec(_DEVICE_TYPE)
    assert spec is not None, "LMCache did not discover ExampleDeviceSpec"
    assert spec.device_type == _DEVICE_TYPE

    torch_dev, detected_device_type = get_torch_device()
    assert detected_device_type == _DEVICE_TYPE
    assert torch_dev is torch.cpu
    assert lmcache.torch_device_type == _DEVICE_TYPE
    assert current_device_spec.device_type == _DEVICE_TYPE

    ops = resolve_device_ops(_DEVICE_TYPE)
    assert type(ops).__name__ == "ExampleDeviceOps"

    wrapper_factory = resolve_kv_wrapper_factory(_DEVICE_TYPE)
    wrapped_tensor = wrapper_factory(torch.zeros(4, dtype=torch.float32))
    assert getattr(wrapped_tensor, "device_uuid", None) == "cpu"
    assert tuple(getattr(wrapped_tensor, "shape", ())) == (4,)

    return {
        "device_type": detected_device_type,
        "torch_module_name": spec.torch_module_name,
        "ops_cls": type(ops).__name__,
    }


def main() -> None:
    """Run the validation and print a short success summary."""
    result = validate_install()
    print("LMCache example device validation passed.")
    for key, value in result.items():
        print(f"{key}={value}")


if __name__ == "__main__":
    main()
