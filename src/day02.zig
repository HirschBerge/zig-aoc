const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;
const test_data =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
;

fn absdiff(a: u32, b: u32) u32 {
    return if (a > b) a - b else b - a;
}

const data = @embedFile("data/day02.txt");
pub fn parse_data(datums: []const u8) !u16 {
    var lines = splitSca(u8, datums, '\n');
    var total: u16 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var numbers = try std.ArrayList(u32).initCapacity(gpa, 0);
        defer numbers.deinit(gpa);
        var digits = splitSca(u8, line, ' ');
        while (digits.next()) |num| {
            try numbers.append(gpa, try parseInt(u32, num, 10));
        }
        var going_down: ?bool = null;
        var is_safe: bool = true;
        var it = std.mem.window(u32, numbers.items, 2, 1);
        while (it.next()) |chunk| {
            const prev = chunk[0];
            const current = chunk[1];
            std.debug.print("p {d} c {d}\n", .{ prev, current });

            if ((prev == current)) {
                is_safe = false;
                std.debug.print("Equal\n", .{});
                break;
            }
            if (prev < current) {
                if (going_down == true) {
                    is_safe = false;
                    std.debug.print("Going down to going up\n", .{});
                    break;
                }
                going_down = false;
            } else if (prev > current) {
                if (going_down == false) {
                    is_safe = false;
                    std.debug.print("Going up to going down\n", .{});
                    break;
                }
                going_down = true;
            }
            if (absdiff(prev, current) >= 4) {
                print("Large change: {d}\n", .{absdiff(prev, current)});
                is_safe = false;
                break;
            }
        }
        // std.debug.print("Total Safe: {d}  -- ", .{total});
        if (is_safe) total += 1;
        std.debug.print("{any}\n", .{numbers.items});
    }
    return total;
}
pub fn part_one() !void {
    std.debug.print("Part 1 Saftey Score: {d}\n", .{try parse_data(data)});
}
pub fn part_two() void {
    std.debug.print("Lorem Ipsum\n", .{});
}
pub fn main() !void {
    try part_one();
    part_two();
}
test "test parse" {
    const testing = std.testing;
    const result = try parse_data(test_data);
    try testing.expectEqual(2, result);
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
