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
for (const [raw, expected] of [[0, 0], [8, 80], [9, 90], [10, 100]]) {
    queue = [[3, 0, 64, 1, raw]];
    const result = plugin.GetBattery();
    assert.equal(result.percentage, expected);
    assert.equal(result.charging, undefined);
    assert.match(result.name, /约数/);
}
for (const invalid of [[3, 0, 64, 1, 11], [3, 0, 64, 1, 99], [3, 1, 64, 1, 8], [3, 0, 65, 1, 8], [4, 0, 64, 1, 8], [3, 0, 64, 1], [3, 0, 64, 1, 8, 0]]) {
    queue = [invalid];
    assert.equal(plugin.GetBattery(), null);
}
queue = [];
reads = 0;
assert.equal(plugin.GetBattery(), null);
assert.equal(reads, 8);
device.read = () => { throw new Error("unplugged"); };
assert.equal(plugin.GetBattery(), null);
console.log("PASS: JS identity, read-only, report parsing, timeouts and unplug handling");
