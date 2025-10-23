const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const test_data =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
;
const data = @embedFile("data/day01.txt");

fn absdiff(a: u32, b: u32) u32 {
    return if (a > b) a - b else b - a;
}

const Pair = struct {
    left: []u32,
    right: []u32,
    pub fn prnt(self: Pair) void {
        for (self.left, self.right) |l, r| {
            print("{d} - {d}\n", .{ l, r });
        }
    }
    pub fn srt(self: Pair) void {
        sort(u32, self.left, {}, asc(u32));
        sort(u32, self.right, {}, asc(u32));
    }
    pub fn sum(self: Pair) u32 {
        var total: u32 = 0;
        for (self.left, self.right) |l, r| {
            total += absdiff(l, r);
        }
        return total;
    }
    pub fn find_similarity(self: Pair) !usize {
        var similarity: usize = 0;
        for (self.left) |target| {
            var count_seen: u32 = 0;
            for (self.right) |num| {
                if (target == num) {
                    count_seen += 1;
                }
            }
            similarity += (count_seen * target);
        }
        return similarity;
    }
};
pub fn parse_data(datums: []const u8) !Pair {
    var lines = splitSca(u8, datums, '\n');
    var l_list = try std.ArrayList(u32).initCapacity(gpa, 0);
    var r_list = try std.ArrayList(u32).initCapacity(gpa, 0);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var set: [2]u32 = undefined;
        var count: u8 = 0;
        var pairs = splitAny(u8, line, " \t");
        while (pairs.next()) |half| {
            if (half.len > 0) {
                if (count < 2) {
                    set[count] = try parseInt(u32, half, 10);
                }
                count += 1;
            }
        }
        try l_list.append(gpa, set[0]);
        try r_list.append(gpa, set[1]);
    }
    var data_store = Pair{
        .left = l_list.items,
        .right = r_list.items,
    };
    data_store.srt();
    return data_store;
}

pub fn part_one() !void {
    const parsed_data = try parse_data(data);
    std.debug.print("Part 1 distance: {d}\n", .{parsed_data.sum()});
}
pub fn part_two() !void {
    const my_pair = try parse_data(data);
    std.debug.print("Part 2 similarity: {d}\n", .{try my_pair.find_similarity()});
}

pub fn main() !void {
    std.debug.print("Day One!\n", .{});
    try part_one();
    try part_two();
}

test "sort data" {
    const testing = std.testing;
    const my_pair = try parse_data(test_data);
    const expected_left = [_]u32{ 1, 2, 3, 3, 3, 4 };
    const expected_right = [_]u32{ 3, 3, 3, 4, 5, 9 };

    // 5. Assert that the sorted slices match the expected results
    try testing.expectEqualSlices(u32, &expected_left, my_pair.left);
    try testing.expectEqualSlices(u32, &expected_right, my_pair.right);
}

test "sum data" {
    const testing = std.testing;
    const my_pair = try parse_data(test_data);
    const tot = my_pair.sum();
    const expected: u32 = 11;
    try testing.expectEqual(expected, tot);
}

test "part two diff" {
    const testing = std.testing;
    const my_pair = try parse_data(test_data);
    // const tot = my_pair.sum();
    const similarity = my_pair.find_similarity();
    const expected: u32 = 31;
    try testing.expectEqual(expected, similarity);
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
