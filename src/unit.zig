const std = @import("std");
const EnumArray = std.EnumArray;
const assert = std.debug.assert;

const MovementType = @import("terrain.zig").MovementType;

pub const Range = struct { min: u4, max: u4 };

pub const UnitType = enum {
    Infantry,
    Mech,
    AntiAir,
    APC,
    Artillery,
    MediumTank,
    MegaTank,
    Neotank,
    Tank,
    Missile,
    Recon,
    Rocket,
    Battleship,
    Carrier,
    Cruiser,
    Submarine,
    Piperunner,
    BlackBoat,
    Lander,
    BattleCopter,
    BlackBomb,
    Bomber,
    Fighter,
    Stealth,
    TransportCopter,

    pub fn getMovementType(unitType: UnitType) MovementType {
        switch (unitType) {
            .Infantry => MovementType.Foot,
            .Mech => MovementType.Mech,
            .AntiAir, .APC, .Artillery, .MediumTank, .MegaTank, .Neotank, .Tank => MovementType.Tread,
            .Missile, .Recon, .Rocket => MovementType.Tire,
            .Carrier, .Cruiser, .Battleship, .Submarine => MovementType.Ship,
            .Lander, .BlackBoat => MovementType.Lander,
            .BattleCopter, .BlackBomb, .Fighter, .Stealth, .TransportCopter => MovementType.Air,
        }
    }

    pub fn getMaxFuel(unitType: UnitType) u8 {
        switch (unitType) {
            .BlackBomb => 45,
            .Artillery, .MediumTank, .MegaTank, .Missile, .Rocket, .BlackBoat => 50,
            .AntiAir, .APC, .Submarine, .Stealth => 60,
            .Tank, .Mech => 70,
            .Recon => 80,
            else => 99,
        }
    }

    pub fn getMovement(unitType: UnitType) u8 {
        switch (unitType) {
            .Mech => 2,
            .Infantry => 3,
            .MegaTank, .Missile => 4,
            .Artillery, .Battleship, .Carrier, .MediumTank, .Rocket, .Submarine => 5,
            .AntiAir, .APC, .BattleCopter, .Cruiser, .Lander, .Neotank, .Stealth, .TransportCopter, .Tank => 6,
            .BlackBoat, .Bomber => 7,
            .Recon => 8,
            .BlackBomb, .Fighter, .Piperunner => 9,
        }
    }

    pub fn getRange(unitType: UnitType) Range {
        switch (unitType) {
            .APC, .Lander, .TransportCopter, .BlackBoat, .BlackBomb => Range{ .min = 0, .max = 0 },
            .Artillery => Range{ .min = 2, .max = 3 },
            .Missile, .Rocket => Range{ .min = 3, .max = 5 },
            .Piperunner => Range{ .min = 2, .max = 5 },
            .Battleship => Range{ .min = 2, .max = 6 },
            .Carrier => Range{ .min = 3, .max = 8 },
            else => Range{ .min = 1, .max = 1 },
        }
    }

    pub fn getCost(unitType: UnitType) u32 {
        switch (unitType) {
            .Infantry => 1000,
            .Mech => 3000,
            .Recon => 4000,
            .APC => 5000,
            .TransportCopter => 5000,
            .Artillery => 6000,
            .Tank => 7000,
            .BlackBoat => 7500,
            .AntiAir => 8000,
            .BattleCopter => 9000,
            .Lander => 12000,
            .Missile => 12000,
            .Rocket => 15000,
            .MediumTank => 16000,
            .Cruiser => 18000,
            .Submarine => 20000,
            .Fighter => 20000,
            .Piperunner => 20000,
            .Neotank => 22000,
            .Bomber => 22000,
            .Stealth => 24000,
            .BlackBomb => 25000,
            .MegaTank => 28000,
            .Battleship => 28000,
            .Carrier => 30000,
        }
    }

    pub fn getBaseDamage(attacker: UnitType, defender: UnitType) u8 {
        const attackerRow = primaryWeaponBaseDamageTable.getPtrConst(attacker);
        return attackerRow.*.get(defender);
    }
};

fn gen_base_damage_array(csvString: []const u8) EnumArray(UnitType, EnumArray(UnitType, u8)) {
    @setEvalBranchQuota(100_000);
    const defaultRow = EnumArray(UnitType, u8).initFill(0);
    var table = EnumArray(UnitType, EnumArray(UnitType, u8))
        .initFill(defaultRow);
    var columnTypes: [32]UnitType = undefined;
    var col = 0;
    var row = 0;
    var attacker: UnitType = undefined;

    var lineIt = std.mem.tokenizeScalar(u8, csvString, '\n');

    while (lineIt.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ',');
        col = 0;
        if (row == 0) {
            _ = it.next(); // skip first column header (atk unit type)
            col = 1;
        }
        while (it.next()) |token| {
            if (row == 0) {
                columnTypes[col] = std.enums.nameCast(UnitType, token);
                col += 1;
            } else if (col == 0) {
                attacker = std.enums.nameCast(UnitType, token);
                col += 1;
            } else {
                const baseAttack: u8 = if (token[0] == '-') 0 else try std.fmt.parseInt(u8, token, 10);
                const currentDefendingType = columnTypes[col];
                table.getPtr(attacker).set(currentDefendingType, baseAttack);
                col += 1;
            }
        }
        row += 1;
    }
    return table;
}

const init_base_damage = @embedFile("resources/attack-table.csv");
const primaryWeaponBaseDamageTable = gen_base_damage_array(init_base_damage);

pub const Unit = struct { id: u16, type: UnitType, health: u8, fuel: u8, ammo: u8 };

test "print unit base attack table" {
    for (std.enums.values(UnitType)) |attacker| {
        for (std.enums.values(UnitType)) |defender| {
            const baseDamage = UnitType.getBaseDamage(attacker, defender);
            switch (attacker) {
                .APC, .Lander, .TransportCopter, .BlackBoat => assert(baseDamage == 0),
                else => {},
            }
            std.debug.print("{s}\t{s}\t{d}\n", .{ @tagName(attacker), @tagName(defender), baseDamage });
        }
    }
}
