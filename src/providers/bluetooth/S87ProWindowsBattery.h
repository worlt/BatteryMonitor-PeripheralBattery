#pragma once

#include "src/core/BatteryDevice.h"
#include <optional>

std::optional<BatteryDevice> readS87ProWindowsBattery(const std::wstring &name, const std::wstring &deviceId);

