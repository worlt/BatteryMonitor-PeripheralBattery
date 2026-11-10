#pragma once
#include "BatteryDevice.h"

// Apply only to the published copy, never to provider snapshots / sticky cache.
inline void applyManualCharging(BatteryDevice &device, bool enabled)
{
    device.chargingManual = false;
    if (device.chargingKnown) return;
    device.charging = false;
    if (enabled && device.connected && !device.stale) {
        device.charging = true;
        device.chargingManual = true;
    }
}

inline const char *chargingSource(const BatteryDevice &device)
{
    if (device.chargingManual) return "manual";
    return device.chargingKnown ? "device" : "unknown";
}
