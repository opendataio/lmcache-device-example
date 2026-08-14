# SPDX-License-Identifier: Apache-2.0
"""Example out-of-tree DeviceSpec implementation."""

# Future
from __future__ import annotations

# Standard
from typing import TYPE_CHECKING
import os

# First Party
from lmcache.v1.platform.cpu import CpuDeviceSpec

if TYPE_CHECKING:
    # First Party
    from lmcache.v1.platform.base.device_ops import DeviceOps

_ENABLE_ENV_VAR = "LMCACHE_DEVICE_EXAMPLE_ENABLE"


def _is_enabled() -> bool:
    """Return whether the example backend is explicitly enabled."""
    return os.environ.get(_ENABLE_ENV_VAR) == "1"


class ExampleDeviceSpec(CpuDeviceSpec):
    """Example out-of-tree backend bound to LMCache's CPU primitives.

    The backend is disabled by default and only reports available when
    ``LMCACHE_DEVICE_EXAMPLE_ENABLE=1`` is set. This keeps the wheel safe to
    install for packaging tests while still allowing explicit selection via
    ``DEVICE_TYPE=example_cpu``.
    """

    @property
    def device_type(self) -> str:
        return "example_cpu"

    @property
    def torch_module_name(self) -> str:
        return "cpu"

    @property
    def ops_cls(self) -> type[DeviceOps]:
        # First Party
        from lmcache_device_example.device_ops import ExampleDeviceOps

        return ExampleDeviceOps

    def is_available(self) -> bool:
        """Return ``True`` only when the example backend is explicitly enabled."""
        if not _is_enabled():
            return False

        try:
            # Third Party
            import torch

            return hasattr(torch, self.torch_module_name)
        except Exception:
            return False
