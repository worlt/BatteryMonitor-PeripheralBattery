#include "S87ProWindowsBattery.h"

#include <windows.h>
#include <setupapi.h>
#include <algorithm>
#include <cwctype>
#include <map>
#include <optional>
#include <string>

namespace
{
    const DEVPROPKEY batteryKey = {{0x104ea319, 0x6ee2, 0x4701, {0xbd, 0x47, 0x8d, 0xdb, 0xf4, 0x25, 0xbb, 0xe5}}, 2};
    const DEVPROPKEY connectionKey = {{0x83da6326, 0x97a6, 0x4088, {0x94, 0x53, 0xa1, 0x92, 0x3f, 0x57, 0x3b, 0x29}}, 15};
    const DEVPROPKEY containerKey = {{0x8c7ed206, 0x3f8a, 0x4827, {0xb3, 0xab, 0xae, 0x9e, 0x1f, 0xae, 0xfc, 0x6c}}, 2};
    const DEVPROPKEY nameKey = {{0xb725f130, 0x47ef, 0x101a, {0xa5, 0xf1, 0x02, 0x60, 0x8c, 0x9e, 0xeb, 0xac}}, 10};

    std::wstring lower(std::wstring value)
    {
        std::transform(value.begin(), value.end(), value.begin(), [](wchar_t character) { return std::towlower(character); });
        return value;
    }
    std::wstring address(const std::wstring &value)
    {
        const std::wstring normalized = lower(value);
        std::wstring found;
        const auto isHex = [](wchar_t character) {
            return (character >= L'0' && character <= L'9') || (character >= L'a' && character <= L'f');
        };
        for (size_t position = 0; position < normalized.size(); ++position)
        {
            if (position + 17 <= normalized.size())
            {
                std::wstring candidate;
                bool valid = true;
                for (size_t offset = 0; offset < 17; ++offset)
                {
                    const wchar_t character = normalized[position + offset];
                    if (offset % 3 == 2) valid = valid && character == L':';
                    else { valid = valid && isHex(character); candidate += character; }
                }
                if (valid) { found = candidate; position += 16; continue; }
            }
            if (position + 12 > normalized.size() || (position > 0 && isHex(normalized[position - 1]))) continue;
            const std::wstring candidate = normalized.substr(position, 12);
            if (std::all_of(candidate.begin(), candidate.end(), isHex) &&
                (position + 12 == normalized.size() || !isHex(normalized[position + 12]))) {
                found = candidate;
                position += 11;
            }
        }
        return found;
    }
    template <typename Value>
    std::optional<Value> property(HDEVINFO devices, SP_DEVINFO_DATA &info, const DEVPROPKEY &key, DEVPROPTYPE expected)
    {
        Value value{};
        DEVPROPTYPE type = 0;
        DWORD size = 0;
        if (!SetupDiGetDevicePropertyW(devices, &info, &key, &type, reinterpret_cast<PBYTE>(&value), sizeof(value), &size, 0) ||
            type != expected || size != sizeof(value)) return std::nullopt;
        return value;
    }
    std::wstring propertyName(HDEVINFO devices, SP_DEVINFO_DATA &info)
    {
        wchar_t text[512]{};
        DEVPROPTYPE type = 0;
        DWORD size = 0;
        if (!SetupDiGetDevicePropertyW(devices, &info, &nameKey, &type, reinterpret_cast<PBYTE>(text), sizeof(text), &size, 0) ||
            type != DEVPROP_TYPE_STRING) return {};
        return text;
    }
    struct Group
    {
        std::optional<int> percentage;
        bool connected = false;
        bool matched = false;
        std::wstring deviceAddress;
    };
}

std::optional<BatteryDevice> readS87ProWindowsBattery(const std::wstring &name, const std::wstring &deviceId)
{
    const std::wstring normalized = lower(name);
    if (normalized.find(L"s87pro") == std::wstring::npos && normalized.find(L"s87 pro") == std::wstring::npos) return std::nullopt;
    const std::wstring requestedAddress = address(deviceId);
    HDEVINFO devices = SetupDiGetClassDevsW(nullptr, nullptr, nullptr, DIGCF_ALLCLASSES | DIGCF_PRESENT);
    if (devices == INVALID_HANDLE_VALUE) return std::nullopt;
    std::map<std::wstring, Group> groups;
    for (DWORD index = 0; ; ++index)
    {
        SP_DEVINFO_DATA info{};
        info.cbSize = sizeof(info);
        if (!SetupDiEnumDeviceInfo(devices, index, &info)) break;
        wchar_t instance[1024]{};
        if (!SetupDiGetDeviceInstanceIdW(devices, &info, instance, 1024, nullptr)) continue;
        const std::wstring instanceId = lower(instance);
        if (instanceId.rfind(L"bth", 0) != 0 && instanceId.rfind(L"hid", 0) != 0) continue;
        const auto container = property<GUID>(devices, info, containerKey, DEVPROP_TYPE_GUID);
        std::wstring groupId = instanceId;
        if (container)
        {
            const auto *bytes = reinterpret_cast<const unsigned char *>(&*container);
            groupId.clear();
            for (size_t offset = 0; offset < sizeof(GUID); ++offset)
            {
                groupId += L"0123456789abcdef"[bytes[offset] >> 4];
                groupId += L"0123456789abcdef"[bytes[offset] & 15];
            }
        }
        Group &group = groups[groupId];
        const std::wstring nodeName = lower(propertyName(devices, info));
        if (nodeName == normalized)
        {
            group.matched = true;
            group.deviceAddress = address(instanceId);
        }
        const auto percentage = property<BYTE>(devices, info, batteryKey, DEVPROP_TYPE_BYTE);
        if (percentage && *percentage <= 100) group.percentage = *percentage;
        const auto connected = property<DEVPROP_BOOLEAN>(devices, info, connectionKey, DEVPROP_TYPE_BOOLEAN);
        if (connected && *connected != DEVPROP_FALSE) group.connected = true;
    }
    SetupDiDestroyDeviceInfoList(devices);
    const Group *selected = nullptr;
    for (const auto &[groupId, group] : groups)
    {
        if (!group.matched || !group.connected || !group.percentage) continue;
        if (!requestedAddress.empty() && group.deviceAddress != requestedAddress) continue;
        if (selected) return std::nullopt;
        selected = &group;
    }
    if (!selected) return std::nullopt;
    BatteryDevice result;
    result.id = deviceId;
    result.name = name;
    result.type = BatteryDevice::Type::Bluetooth;
    result.percentage = *selected->percentage;
    result.level = result.percentage >= 80 ? BatteryLevel::Full : result.percentage >= 50 ? BatteryLevel::Medium :
                   result.percentage >= 20 ? BatteryLevel::Low : BatteryLevel::Empty;
    result.connected = true;
    return result;
}
