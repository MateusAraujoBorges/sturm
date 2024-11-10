const std = @import("std");
const Terrain = @import("terrain.zig").Terrain;
const assert = std.debug.assert;

pub const GameMap = struct {
    width: u8,
    height: u8,
    tiles: []Terrain,

    pub fn init(width: u8, height: u8, tiles: []Terrain) GameMap {
        assert(tiles.len == width * height);
        return GameMap{ .width = width, .height = height, .tiles = tiles };
    }

    pub fn getTile(self: GameMap, x: u8, y: u8) Terrain {
        return self.tiles[x * self.width + y];
    }
};

pub fn printGameMap(map: GameMap) void {
    for (map.tiles, 0..) |tile, i| {
        if (i % map.width == 0) {
            std.debug.print("\n", .{});
        }
        switch (tile) {
            .Road => std.debug.print("=", .{}),
            .Plain => std.debug.print(".", .{}),
            .Wood => std.debug.print("&", .{}),
            .Mountain => std.debug.print("^", .{}),
            .River => std.debug.print("'", .{}),
            .Shoal => std.debug.print(",", .{}),
            .Sea => std.debug.print("\"", .{}),
            .Reef => std.debug.print(";", .{}),
            .Pipe => std.debug.print("|", .{}),
            .MissileSilo => std.debug.print("`", .{}),
            .HQ => std.debug.print("h", .{}),
            .City => std.debug.print("c", .{}),
            .Base => std.debug.print("b", .{}),
            .Airport => std.debug.print("a", .{}),
            .Port => std.debug.print("p", .{}),
            .CommTower => std.debug.print("t", .{}),
            .Lab => std.debug.print("l", .{}),
        }
    }
}

test "printing map" {
    var tiles = [_]Terrain{
        .Plain, .Plain, .Plain,
        .Road,  .Wood,  .Road,
        .Plain, .Plain, .Plain,
    };

    const map = GameMap.init(3, 3, &tiles);
    printGameMap(map);
}
