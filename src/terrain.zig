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
    const table = std.EnumArray(MovementType, std.EnumArray(Terrain, bool)).init(bool, false);
    // infantry stuff
    table[MovementType.Foot][Terrain.Sea] = true;
    table[MovementType.Foot][Terrain.Reef] = true;
    table[MovementType.Foot][Terrain.Pipe] = true;
    table[MovementType.Mech][Terrain.Sea] = true;
    table[MovementType.Mech][Terrain.Reef] = true;
    table[MovementType.Mech][Terrain.Pipe] = true;

    //vehicle stuff
    table[MovementType.Tire][Terrain.Sea] = true;
    table[MovementType.Tire][Terrain.Reef] = true;
    table[MovementType.Tire][Terrain.Pipe] = true;
    table[MovementType.Tire][Terrain.Mountain] = true;
    table[MovementType.Tire][Terrain.River] = true;
    table[MovementType.Tread][Terrain.Sea] = true;
    table[MovementType.Tread][Terrain.Reef] = true;
    table[MovementType.Tread][Terrain.Pipe] = true;
    table[MovementType.Tread][Terrain.Mountain] = true;
    table[MovementType.Tread][Terrain.River] = true;

    // sea stuff
    table[MovementType.Ship][Terrain.Plain] = true;
    table[MovementType.Ship][Terrain.Wood] = true;
    table[MovementType.Ship][Terrain.Mountain] = true;
    table[MovementType.Ship][Terrain.River] = true;
    table[MovementType.Ship][Terrain.Road] = true;
    table[MovementType.Ship][Terrain.Shoal] = true;
    table[MovementType.Ship][Terrain.Pipe] = true;
    table[MovementType.Ship][Terrain.HQ] = true;
    table[MovementType.Ship][Terrain.City] = true;
    table[MovementType.Ship][Terrain.Base] = true;
    table[MovementType.Ship][Terrain.Airport] = true;
    table[MovementType.Ship][Terrain.Lab] = true;
    table[MovementType.Ship][Terrain.CommTower] = true;
    table[MovementType.Ship][Terrain.MissileSilo] = true;

    table[MovementType.Lander][Terrain.Plain] = true;
    table[MovementType.Lander][Terrain.Wood] = true;
    table[MovementType.Lander][Terrain.Mountain] = true;
    table[MovementType.Lander][Terrain.River] = true;
    table[MovementType.Lander][Terrain.Road] = true;
    table[MovementType.Lander][Terrain.Pipe] = true;
    table[MovementType.Lander][Terrain.HQ] = true;
    table[MovementType.Lander][Terrain.City] = true;
    table[MovementType.Lander][Terrain.Base] = true;
    table[MovementType.Lander][Terrain.Airport] = true;
    table[MovementType.Lander][Terrain.Lab] = true;
    table[MovementType.Lander][Terrain.CommTower] = true;
    table[MovementType.Lander][Terrain.MissileSilo] = true;

    // air stuff
    table[MovementType.Air][Terrain.Pipe] = true;

    // pipe stuff
    table[MovementType.Pipe][Terrain.Plain] = true;
    table[MovementType.Pipe][Terrain.Wood] = true;
    table[MovementType.Pipe][Terrain.Mountain] = true;
    table[MovementType.Pipe][Terrain.River] = true;
    table[MovementType.Pipe][Terrain.Road] = true;
    table[MovementType.Pipe][Terrain.Sea] = true;
    table[MovementType.Pipe][Terrain.Reef] = true;
    table[MovementType.Pipe][Terrain.Shoal] = true;
    table[MovementType.Pipe][Terrain.HQ] = true;
    table[MovementType.Pipe][Terrain.City] = true;
    table[MovementType.Pipe][Terrain.Airport] = true;
    table[MovementType.Pipe][Terrain.Lab] = true;
    table[MovementType.Pipe][Terrain.Port] = true;
    table[MovementType.Pipe][Terrain.CommTower] = true;
    table[MovementType.Pipe][Terrain.MissileSilo] = true;

    break :init_illegal_movement_table table;
};

const movementCostTable = init_mvt_cost_table: {
    const table = std.EnumArray(MovementType, std.EnumArray(Terrain, u8)).init(u8, 9999);
    // infantry stuff
    table[MovementType.Foot][Terrain.Plain] = 1;
    table[MovementType.Foot][Terrain.Mountain] = 2;
    table[MovementType.Foot][Terrain.Wood] = 1;
    table[MovementType.Foot][Terrain.River] = 2;
    table[MovementType.Foot][Terrain.Road] = 1;
    table[MovementType.Foot][Terrain.Shoal] = 1;
    table[MovementType.Foot][Terrain.MissileSilo] = 1;

    table[MovementType.Mech][Terrain.Plain] = 1;
    table[MovementType.Mech][Terrain.Mountain] = 1;
    table[MovementType.Mech][Terrain.Wood] = 1;
    table[MovementType.Mech][Terrain.River] = 1;
    table[MovementType.Mech][Terrain.Road] = 1;
    table[MovementType.Mech][Terrain.Shoal] = 1;
    table[MovementType.Mech][Terrain.MissileSilo] = 1;

    // vehicle stuff
    table[MovementType.Tire][Terrain.Plain] = 2;
    table[MovementType.Tire][Terrain.Wood] = 3;
    table[MovementType.Tire][Terrain.Road] = 1;
    table[MovementType.Tire][Terrain.Shoal] = 1;
    table[MovementType.Tire][Terrain.MissileSilo] = 1;

    table[MovementType.Tread][Terrain.Plain] = 1;
    table[MovementType.Tread][Terrain.Wood] = 2;
    table[MovementType.Tread][Terrain.Road] = 1;
    table[MovementType.Tread][Terrain.Shoal] = 1;
    table[MovementType.Tread][Terrain.MissileSilo] = 1;

    // sea stuff
    table[MovementType.Ship][Terrain.Sea] = 1;
    table[MovementType.Ship][Terrain.Reef] = 2;

    table[MovementType.Lander][Terrain.Sea] = 1;
    table[MovementType.Lander][Terrain.Reef] = 2;
    table[MovementType.Lander][Terrain.Shoal] = 1;

    // properties and pipes
    for (std.enums.values(MovementType)) |movementType| {
        if (movementType == .Pipe or movementType == .Ship or movementType == .Lander) {
            continue;
        }
        for (std.enums.values(Terrain)) |terrain| {
            if (terrain.isProperty()) {
                table[movementType][terrain] = 1;
            }
        }
    }
    table[MovementType.Ship][Terrain.Port] = 1;
    table[MovementType.Lander][Terrain.Port] = 1;
    table[MovementType.Pipe][Terrain.Pipe] = 1;
    table[MovementType.Pipe][Terrain.Base] = 1;
    break :init_mvt_cost_table table;
};

pub fn getMovementCost(movementType: MovementType, terrain: Terrain) u8 {
    return movementCostTable[movementType][terrain];
}

pub fn isLegalMovement(movementType: MovementType, terrain: Terrain) bool {
    return !illegalMovementTable[movementType][terrain];
}
