const std = @import("std");
const testing = std.testing;
const unit = @import("unit.zig");
const gameMap = @import("gameMap.zig");

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

test {
    _ = unit;
    _ = gameMap;
}
