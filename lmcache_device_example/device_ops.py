# SPDX-License-Identifier: Apache-2.0
"""Example DeviceOps implementation for an out-of-tree LMCache backend."""

# Future
from __future__ import annotations

# Standard
from typing import ClassVar

# First Party
from lmcache.v1.platform.cpu.device_ops import CpuDeviceOps


class ExampleDeviceOps(CpuDeviceOps):
    """Example DeviceOps that reuses LMCache's CPU baseline behavior."""

    device_type: ClassVar[str] = "example_cpu"
