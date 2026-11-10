import assert from "node:assert/strict";
import fs from "node:fs";

const source = fs.readFileSync(new URL("../plugins/peripheral-battery/gm3323d-readonly.js", import.meta.url), "utf8");
const plugin = await import("data:text/javascript;base64," + Buffer.from(source).toString("base64"));
let reads = 0;
let queue = [];
globalThis.device = {
    usagePage: () => 10,
    read: (length, timeout) => {
        reads++;
        assert.equal(length, 5);
        assert.equal(timeout, 500);
        return queue.shift() ?? null;
    },
    log: () => {}
};
assert.equal(plugin.VendorId(), 0x1d57);
assert.equal(plugin.ProductId(), 0xfa60);
assert.match(plugin.Name(), /read-only/);
assert.doesNotMatch(source, /device\.(write|sendFeature|getFeature)\s*\(/);
device.usagePage = () => 11;
assert.equal(plugin.GetBattery(), null);
assert.equal(reads, 0);
device.usagePage = () => 10;
// The charging capture was 03 01 40 01 0a. Both observed power
// states must survive parsing, across all supported 10% battery steps.
for (const powerState of [1, 0]) {
    for (let step = 0; step <= 10; step++) {
        queue = [[3, powerState, 64, 1, step]];
        const result = plugin.GetBattery();
        assert.ok(result, `power=${powerState}, step=${step} must remain visible`);
        assert.equal(result.percentage, step * 10);
        assert.equal(result.charging, powerState === 1);
        assert.equal(result.wired, undefined); // Charging does not identify the data transport.
        assert.match(result.name, /约数/);
    }
}
queue = [new Uint8Array([3, 1, 64, 1, 10])];
assert.equal(plugin.GetBattery().charging, true);
queue = [[3, 2, 64, 1, 8], [3, 1, 64, 1, 8]];
assert.equal(plugin.GetBattery().percentage, 80); // Skip malformed reports, not charging reports.
for (const invalid of [[3, 0, 64, 1, 11], [3, 0, 64, 1, 99], [3, 2, 64, 1, 8], [3, 255, 64, 1, 8], [3, 0, 65, 1, 8], [3, 0, 64, 0, 8], [3, 0, 64, 1, 1.5], [4, 0, 64, 1, 8], [3, 0, 64, 1], [3, 0, 64, 1, 8, 0]]) {
    queue = [invalid];
    assert.equal(plugin.GetBattery(), null);
}
queue = [];
reads = 0;
assert.equal(plugin.GetBattery(), null);
assert.equal(reads, 8);
device.read = () => { throw new Error("unplugged"); };
assert.equal(plugin.GetBattery(), null);
console.log("PASS: JS identity, read-only, charging/discharging steps, report validation, timeouts and unplug handling");
