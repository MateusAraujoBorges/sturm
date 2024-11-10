const std = @import("std");
const assert = std.debug.assert;

pub const MovementType = enum { Foot, Mech, Tire, Tread, Ship, Lander, Air, Pipe };

pub const Weather = enum { Clear, Rain, Snow, Sandstorm };

pub const Terrain = enum {
    Road,
    Plain,
    Wood,
    Mountain,
    River,
    Shoal,
    Sea,
    Reef,
    Pipe,
    MissileSilo,
    HQ,
    City,
    Base,
    Airport,
    Port,
    CommTower,
    Lab,

    pub fn isProperty(terrain: Terrain) bool {
        switch (terrain) {
            .HQ, .City, .Base, .Airport, .Port, .CommTower, .Lab => true,
            _ => false,
        }
    }

    pub fn defenseStars(terrain: Terrain) u8 {
        switch (terrain) {
            .Plain, .Reef => 1,
            .Wood => 2,
            .MissileSilo, .City, .Base, .Airport, .Port, .Lab, .CommTower => 3,
            .Mountain, .HQ => 4,
            else => 0,
        }
    }
};

const illegalMovementTable = init_illegal_movement_table: {
    var table = std.EnumArray(MovementType, std.EnumArray(Terrain, bool)).init(bool, false);
    // infantry stuff
    table.getPtr(MovementType.Foot).set(Terrain.Sea, true);
    table.getPtr(MovementType.Foot).set(Terrain.Reef, true);
    table.getPtr(MovementType.Foot).set(Terrain.Pipe, true);
    table.getPtr(MovementType.Mech).set(Terrain.Sea, true);
    table.getPtr(MovementType.Mech).set(Terrain.Reef, true);
    table.getPtr(MovementType.Mech).set(Terrain.Pipe, true);

    //vehicle stuff
    table.getPtr(MovementType.Tire).set(Terrain.Sea, true);
    table.getPtr(MovementType.Tire).set(Terrain.Reef, true);
    table.getPtr(MovementType.Tire).set(Terrain.Pipe, true);
    table.getPtr(MovementType.Tire).set(Terrain.Mountain, true);
    table.getPtr(MovementType.Tire).set(Terrain.River, true);
    table.getPtr(MovementType.Tread).set(Terrain.Sea, true);
    table.getPtr(MovementType.Tread).set(Terrain.Reef, true);
    table.getPtr(MovementType.Tread).set(Terrain.Pipe, true);
    table.getPtr(MovementType.Tread).set(Terrain.Mountain, true);
    table.getPtr(MovementType.Tread).set(Terrain.River, true);

    // sea stuff
    table.getPtr(MovementType.Ship).set(Terrain.Plain, true);
    table.getPtr(MovementType.Ship).set(Terrain.Wood, true);
    table.getPtr(MovementType.Ship).set(Terrain.Mountain, true);
    table.getPtr(MovementType.Ship).set(Terrain.River, true);
    table.getPtr(MovementType.Ship).set(Terrain.Road, true);
    table.getPtr(MovementType.Ship).set(Terrain.Shoal, true);
    table.getPtr(MovementType.Ship).set(Terrain.Pipe, true);
    table.getPtr(MovementType.Ship).set(Terrain.HQ, true);
    table.getPtr(MovementType.Ship).set(Terrain.City, true);
    table.getPtr(MovementType.Ship).set(Terrain.Base, true);
    table.getPtr(MovementType.Ship).set(Terrain.Airport, true);
    table.getPtr(MovementType.Ship).set(Terrain.Lab, true);
    table.getPtr(MovementType.Ship).set(Terrain.CommTower, true);
    table.getPtr(MovementType.Ship).set(Terrain.MissileSilo, true);

    table.getPtr(MovementType.Lander).set(Terrain.Plain, true);
    table.getPtr(MovementType.Lander).set(Terrain.Wood, true);
    table.getPtr(MovementType.Lander).set(Terrain.Mountain, true);
    table.getPtr(MovementType.Lander).set(Terrain.River, true);
    table.getPtr(MovementType.Lander).set(Terrain.Road, true);
    table.getPtr(MovementType.Lander).set(Terrain.Pipe, true);
    table.getPtr(MovementType.Lander).set(Terrain.HQ, true);
    table.getPtr(MovementType.Lander).set(Terrain.City, true);
    table.getPtr(MovementType.Lander).set(Terrain.Base, true);
    table.getPtr(MovementType.Lander).set(Terrain.Airport, true);
    table.getPtr(MovementType.Lander).set(Terrain.Lab, true);
    table.getPtr(MovementType.Lander).set(Terrain.CommTower, true);
    table.getPtr(MovementType.Lander).set(Terrain.MissileSilo, true);

    // air stuff
    table.getPtr(MovementType.Air).set(Terrain.Pipe, true);

    // pipe stuff
    table.getPtr(MovementType.Pipe).set(Terrain.Plain, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Wood, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Mountain, true);
    table.getPtr(MovementType.Pipe).set(Terrain.River, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Road, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Sea, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Reef, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Shoal, true);
    table.getPtr(MovementType.Pipe).set(Terrain.HQ, true);
    table.getPtr(MovementType.Pipe).set(Terrain.City, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Airport, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Lab, true);
    table.getPtr(MovementType.Pipe).set(Terrain.Port, true);
    table.getPtr(MovementType.Pipe).set(Terrain.CommTower, true);
    table.getPtr(MovementType.Pipe).set(Terrain.MissileSilo, true);

    break :init_illegal_movement_table table;
};

const movementCostTable = init_mvt_cost_table: {
    const table = std.EnumArray(MovementType, std.EnumArray(Terrain, u8)).init(u8, 9999);
    // infantry stuff
    table.getPtr(MovementType.Foot).set(Terrain.Plain, 1);
    table.getPtr(MovementType.Foot).set(Terrain.Mountain, 2);
    table.getPtr(MovementType.Foot).set(Terrain.Wood, 1);
    table.getPtr(MovementType.Foot).set(Terrain.River, 2);
    table.getPtr(MovementType.Foot).set(Terrain.Road, 1);
    table.getPtr(MovementType.Foot).set(Terrain.Shoal, 1);
    table.getPtr(MovementType.Foot).set(Terrain.MissileSilo, 1);

    table.getPtr(MovementType.Mech).set(Terrain.Plain, 1);
    table.getPtr(MovementType.Mech).set(Terrain.Mountain, 1);
    table.getPtr(MovementType.Mech).set(Terrain.Wood, 1);
    table.getPtr(MovementType.Mech).set(Terrain.River, 1);
    table.getPtr(MovementType.Mech).set(Terrain.Road, 1);
    table.getPtr(MovementType.Mech).set(Terrain.Shoal, 1);
    table.getPtr(MovementType.Mech).set(Terrain.MissileSilo, 1);

    // vehicle stuff
    table.getPtr(MovementType.Tire).set(Terrain.Plain, 2);
    table.getPtr(MovementType.Tire).set(Terrain.Wood, 3);
    table.getPtr(MovementType.Tire).set(Terrain.Road, 1);
    table.getPtr(MovementType.Tire).set(Terrain.Shoal, 1);
    table.getPtr(MovementType.Tire).set(Terrain.MissileSilo, 1);

    table.getPtr(MovementType.Tread).set(Terrain.Plain, 1);
    table.getPtr(MovementType.Tread).set(Terrain.Wood, 2);
    table.getPtr(MovementType.Tread).set(Terrain.Road, 1);
    table.getPtr(MovementType.Tread).set(Terrain.Shoal, 1);
    table.getPtr(MovementType.Tread).set(Terrain.MissileSilo, 1);

    // sea stuff
    table.getPtr(MovementType.Ship).set(Terrain.Sea, 1);
    table.getPtr(MovementType.Ship).set(Terrain.Reef, 2);

    table.getPtr(MovementType.Lander).set(Terrain.Sea, 1);
    table.getPtr(MovementType.Lander).set(Terrain.Reef, 2);
    table.getPtr(MovementType.Lander).set(Terrain.Shoal, 1);

    // properties and pipes
    for (std.enums.values(MovementType)) |movementType| {
        if (movementType == .Pipe or movementType == .Ship or movementType == .Lander) {
            continue;
        }
        for (std.enums.values(Terrain)) |terrain| {
            if (terrain.isProperty()) {
                table.getPtr(MovementType).set(Terrain, 1);
            }
        }
    }
    table.getPtr(MovementType.Ship).set(Terrain.Port, 1);
    table.getPtr(MovementType.Lander).set(Terrain.Port, 1);
    table.getPtr(MovementType.Pipe).set(Terrain.Pipe, 1);
    table.getPtr(MovementType.Pipe).set(Terrain.Base, 1);
    break :init_mvt_cost_table table;
};

pub fn getMovementCost(movementType: MovementType, terrain: Terrain) u8 {
    return movementCostTable.getPtr(movementType).get(terrain);
}

pub fn isLegalMovement(movementType: MovementType, terrain: Terrain) bool {
    return !illegalMovementTable.getPtr(movementType).get(terrain);
}
