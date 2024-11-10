const std = @import("std");
const unit = @import("unit.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    for (std.enums.values(unit.UnitType)) |attacker| {
        for (std.enums.values(unit.UnitType)) |defender| {
            const baseDamage = unit.UnitType.getBaseDamage(attacker, defender);
            std.debug.print("{}\t->\t{}\t=>{d}\n", .{ @tagName(attacker), @tagName(defender), baseDamage });
        }
    }

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    for (std.enums.values(unit.UnitType)) |attacker| {
        for (std.enums.values(unit.UnitType)) |defender| {
            const baseDamage = unit.UnitType.getBaseDamage(attacker, defender);
            std.debug.print("{}\t->\t{}\t=>{d}\n", .{ @tagName(attacker), @tagName(defender), baseDamage });
        }
    }
}
