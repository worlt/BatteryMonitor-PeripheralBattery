// @min-host-version: 1.4

export function Name() {
    return "GM3323D read-only battery (10% steps)";
}

export function VendorId() {
    return 0x1d57;
}

export function ProductId() {
    return 0xfa60;
}

export function GetBattery() {
    if (typeof device.usagePage !== "function" || device.usagePage() !== 0x000a) {
        return null;
    }
    if (typeof device.read !== "function") {
        return null;
    }
    try {
        for (let attempt = 0; attempt < 8; attempt++) {
            const report = device.read(5, 500);
            // Observed reports: 03 00 40 01 <step> on battery;
            // 03 01 40 01 <step> while charging (GM3323D capture, 2026-11-10).
            // The power-state byte is not part of the fixed report signature.
            if (!report || report.length !== 5 || report[0] !== 0x03 ||
                (report[1] !== 0x00 && report[1] !== 0x01) ||
                report[2] !== 0x40 || report[3] !== 0x01) {
                continue;
            }
            const step = report[4];
            if (!Number.isInteger(step) || step < 0 || step > 10) {
                continue;
            }
            return {
                name: "戴记 GM3323D（约数 / 10% 档位）",
                percentage: step * 10,
                charging: report[1] === 0x01
            };
        }
    } catch (error) {
        device.log("GM3323D input read failed: " + error);
    }
    return null;
}

