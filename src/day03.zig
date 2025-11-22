const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const aoc = @import("aoc.zig");
const util = @import("util.zig");
const gpa = util.gpa;

const InputIterator = aoc.InputIterator;
// const data = @embedFile("data/day03.txt");

pub fn main() !void {
    const start_time = std.time.nanoTimestamp();
    defer {
        const end_time = std.time.nanoTimestamp();
        const elapsed = end_time - start_time;
        const elapsed_us = @divFloor(elapsed, std.time.ns_per_us);
        std.debug.print(" : {d}us\n", .{elapsed_us});
    }
    const input_path = "./src/data/day03.txt";
    var input: InputIterator = try .init(input_path);
    while (input.next()) |value| {
        std.debug.print("{s}\n", .{value});
    }
}

const Lexer = struct {
    data: []const u8,
    index: usize = 0,
    read_ahead: usize = 0,
    ch: u8 = 0,

    const Self = @This();
    pub fn readNumber(self: *Self) []const u8 {
        const start = self.index;
        while (self.isDigit()) self.nextChar();
        return self.data[start..self.index];
    }

    pub fn isDigit(self: *Self) bool {
        return '0' <= self.ch and self.ch <= '9';
    }

    pub fn isLetter(self: *Self) bool {
        return switch (self.ch) {
            'm' => true,
            'u' => true,
            'l' => true,
            'd' => true,
            'o' => true,
            'n' => true,
            't' => true,
            '\'' => true,
            else => false,
        };
    }
};

const TokenType = enum {
    LETTER,
    DIGIT,
    LEFT_PAREN,
    RIGHT_PAREN,
    COMMA,
    SPECIAL,
};

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
