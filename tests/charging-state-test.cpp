#include "src/core/ChargingState.h"
#include "src/rpc/DeviceJson.h"
#include "util/DeviceSettings.h"
#include <QCoreApplication>
#include <QSettings>
#include <QTemporaryDir>
#include <iostream>
#include <cstdlib>
void check(bool condition, const char *name) {
    if (!condition) { std::cerr << "FAIL: " << name << "\n"; std::exit(1); }
}
int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    app.setOrganizationName("ChargingTests");
    app.setApplicationName("Isolated");
    QTemporaryDir dir;
    check(dir.isValid(), "temporary settings directory");
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, dir.path());
    QSettings::setPath(QSettings::IniFormat, QSettings::SystemScope, dir.path());
    BatteryDevice reported;
    check(DeviceJson::toJson(reported).value("chargingSource").toString() == "device", "reported source");
    for (bool charging : {false, true}) {
        reported.charging = charging;
        applyManualCharging(reported, true);
        check(reported.charging == charging && !reported.chargingManual, "never override hardware");
    }
    BatteryDevice unknown;
    unknown.id = L"s87pro";
    unknown.percentage = 44;
    unknown.connected = true;
    unknown.chargingKnown = false;
    auto raw = unknown;
    applyManualCharging(unknown, false);
    check(!unknown.charging && !unknown.chargingManual, "unknown does not mean charging");
    check(DeviceJson::toJson(unknown).value("chargingSource").toString() == "unknown", "unknown source");
    auto before = unknown;
    applyManualCharging(unknown, true);
    check(unknown.charging && unknown.chargingManual && !unknown.chargingKnown, "explicit manual annotation");
    check(unknown.percentage == 44 && raw.percentage == 44 && !raw.charging, "preserve raw reading and percentage");
    check(!sameDisplayContent(before, unknown), "manual toggle refreshes UI");
    check(DeviceJson::signature(before) != DeviceJson::signature(unknown), "manual toggle refreshes RPC");
    check(DeviceJson::toJson(unknown).value("chargingSource").toString() == "manual", "manual provenance in RPC");
    applyManualCharging(unknown, false);
    check(!unknown.charging && !unknown.chargingManual && !unknown.chargingKnown, "clear restores unknown");
    for (bool stale : {false, true}) {
        for (bool connected : {false, true}) {
            unknown.stale = stale;
            unknown.connected = connected;
            applyManualCharging(unknown, true);
            check(unknown.charging == (connected && !stale), "disconnect/stale cannot claim live charging");
        }
    }
    unknown = raw;
    auto known = raw;
    known.chargingKnown = true;
    check(!sameDisplayContent(unknown, known), "knowledge-only transition refreshes UI");
    check(DeviceJson::signature(unknown) != DeviceJson::signature(known), "knowledge-only transition refreshes RPC");
    const QString id = QStringLiteral("BluetoothLE#keyboard/a");
    check(!DeviceSettings::manualCharging(id), "manual setting defaults off");
    DeviceSettings::setTrayVisible(id, true);
    DeviceSettings::setAlertEnabled(id, true);
    DeviceSettings::setManualCharging(id, true);
    check(DeviceSettings::manualCharging(id), "manual preference persists");
    check(!DeviceSettings::manualCharging(QStringLiteral("other")), "settings isolated by device");
    check(DeviceSettings::trayVisible(id) && DeviceSettings::alertEnabled(id), "existing preferences unchanged");
    DeviceSettings::setManualCharging(id, false);
    check(!DeviceSettings::manualCharging(id), "preference removable");
    DeviceSettings::setManualCharging(QString(), true);
    check(!DeviceSettings::manualCharging(QString()), "empty identity ignored");
    std::cout << "PASS: charging unknown/manual/device provenance, cache isolation, UI/RPC changes, stale/disconnect and preferences\n";
    return 0;
}
