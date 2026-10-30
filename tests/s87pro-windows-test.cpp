#include "src/providers/bluetooth/S87ProWindowsBattery.h"
#include <iostream>

int wmain(int count, wchar_t **arguments)
{
    if (count != 3) return 1;
    const std::wstring deviceId = arguments[1];
    const int expected = std::stoi(arguments[2]);
    const auto reading = readS87ProWindowsBattery(L"AULA-S87Pro-1", deviceId);
    if (!reading || reading->percentage != expected || !reading->connected || reading->id != deviceId) return 2;
    if (readS87ProWindowsBattery(L"Different keyboard", deviceId)) return 3;
    if (readS87ProWindowsBattery(L"AULA-S87Pro-1", L"BluetoothLE#BluetoothLE00:00:00:00:00:01-00:00:00:00:00:02")) return 4;
    if (readS87ProWindowsBattery(L"AULA-S87Pro-2", deviceId)) return 5;
    std::wcout << L"PASS: S87Pro Windows property=" << reading->percentage << L"%, exact device identity, mismatched model/address rejected" << std::endl;
    return 0;
}

