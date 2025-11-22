const std = @import("std");

const INPUT_BUFFER_SIZE = 1048576;

/// Checks if a file exists in the given directory. If the file does not exist, it creates it.
/// This is useful for ensuring that input files are present before trying to read them.
///
/// * `dir` - The directory to check for the file in.
/// * `file_name` - The name of the file to check for.
pub fn check_or_create_file(dir: std.fs.Dir, file_name: []const u8) !void {
    var file = dir.openFile(file_name, .{}) catch |err| blk: {
        switch (err) {
            std.fs.File.OpenError.FileNotFound => break :blk null,
            else => return err,
        }
    };

    if (file == null) {
        _ = try dir.createFile(file_name, .{});
    } else {
        file.?.close();
    }
}

/// Represents the two parts of an Advent of Code problem.
pub const Part = enum {
    Part_01,
    Part_02,

    /// Formats the enum value as a string for printing.
    pub fn format(self: Part, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        const str_fmt = switch (self) {
            .Part_01 => "Part 1",
            .Part_02 => "Part 2",
        };

        try writer.print("{s}", .{str_fmt});
    }
};

/// An iterator for reading lines from an input file.
/// It reads the entire file into a buffer and then provides an iterator over the lines.
pub const InputIterator = struct {
    _buffer: [1048576]u8 = undefined,
    _bufLen: usize = 0,
    lines: std.mem.TokenIterator(u8, .any) = undefined,
    split: std.mem.SplitIterator(u8, .any) = undefined,

    const Self = @This();

    /// Initializes the InputIterator from a file path.
    /// It reads the file content into a buffer and prepares a line tokenizer.
    ///
    /// * `path` - The path to the input file.
    pub fn init(path: []const u8) !Self {
        var self = Self{};
        for (self._buffer, 0..) |_, i| {
            self._buffer[i] = '\x00';
        }
        var file = try std.fs.cwd().openFile(path, .{});
        defer file.close();
        self._bufLen = try file.read(&self._buffer);
        self.tokenizeLines();
        return self;
    }

    /// Alternative initializer for the InputIterator.
    /// This version uses a split iterator instead of a token iterator.
    ///
    /// * `path` - The path to the input file.
    pub fn init_(path: []const u8) !Self {
        var self = Self{};
        for (self._buffer, 0..) |_, i| {
            self._buffer[i] = '\x00';
        }
        var file = try std.fs.cwd().openFile(path, .{});
        defer file.close();
        self._bufLen = try file.read(&self._buffer);
        _ = self.splitLines();
        return self;
    }

    /// Sets up the line tokenizer for the buffered input.
    pub fn tokenizeLines(self: *Self) void {
        self.lines = std.mem.tokenizeAny(u8, &self._buffer, "\n\x00");
    }

    /// Sets up the line splitter for the buffered input.
    pub fn splitLines(self: *Self) void {
        self.split = std.mem.splitAny(u8, &self._buffer, "\n\x00");
    }

    /// Returns the next line from the input.
    /// Returns `null` if there are no more lines.
    pub fn next(self: *Self) ?[]const u8 {
        if (@intFromPtr(&self.lines.buffer[0]) != @intFromPtr(&self._buffer[0])) self.lines.buffer = self._buffer[0..];
        if (self.lines.index >= self._bufLen - 1) {
            return null;
        }
        const result = self.lines.peek() orelse {
            return null;
        };
        if (result.len == 0) return null;

        return self.lines.next();
    }

    /// Returns the next line from the input using the split iterator.
    /// Returns `null` if there are no more lines.
    pub fn next_s(self: *Self) ?[]const u8 {
        if (@intFromPtr(&self.split.buffer[0]) != @intFromPtr(&self._buffer[0])) self.split.buffer = self._buffer[0..];
        if (self.split.index.? >= self._bufLen - 1) {
            return null;
        }

        return self.split.next();
    }

    /// Resets the line iterator to the beginning of the input.
    pub fn reset(self: *Self) void {
        self.lines.reset();
    }
};

/// Represents a 2D grid of characters, typically from an Advent of Code puzzle input.
/// Provides helper functions for working with the grid.
pub const CharMap = struct {
    grid_string_buffer: [INPUT_BUFFER_SIZE]u8 = undefined,
    grid_string: []const u8 = undefined,
    grid_string_len: usize = undefined,
    width: usize = undefined,
    height: usize = undefined,

    const Self = @This();

    /// Initializes the CharMap from a file path.
    /// It reads the file into a buffer and calculates the grid dimensions.
    ///
    /// * `input_path` - The path to the input file.
    pub fn init(input_path: []const u8) !Self {
        var self: Self = .{};
        var file = try std.fs.cwd().openFile(input_path, .{});
        defer file.close();
        self.grid_string_len = try file.read(&self.grid_string_buffer);
        self.grid_string = self.grid_string_buffer[0..self.grid_string_len];
        self.width = std.mem.indexOf(u8, &self.grid_string_buffer, "\n").? + 1;
        self.height = self.grid_string_len / self.width;
        return self;
    }

    /// Initializes the CharMap from a slice of bytes.
    /// This is useful for testing or when the grid is already in memory.
    ///
    /// * `input` - A slice of bytes representing the grid.
    pub fn init_slice(input: []const u8) Self {
        var self: Self = .{};

        std.mem.copyForwards(u8, &self.grid_string, input);
        self.grid_string_len = std.mem.indexOf(u8, &self.grid_string, "\x00").?;
        self.width = std.mem.indexOf(u8, &self.grid_string, "\n").? + 1;
        self.height = self.grid_string_len / self.width;
        return self;
    }

    /// Clears the console and prints the grid.
    /// Useful for visualizing the grid during debugging.
    pub fn clearPrint(self: *const Self) !void {
        const writer = std.io.getStdOut().writer();
        try writer.print("\x1B[2J\x1B[H", .{});
        try writer.print("{s}", .{self.grid_string_buffer});
    }

    /// Converts a 1D index into 2D (x, y) coordinates.
    ///
    /// * `i` - The 1D index.
    pub fn getXY(self: *const Self, i: usize) XY {
        return .{ .x = i % self.width, .y = i / self.width };
    }

    /// Converts 2D (x, y) coordinates into a 1D index.
    ///
    /// * `xy` - The 2D coordinates.
    pub fn indexFromXY(self: *const Self, xy: XY) usize {
        return xy.y * self.width + xy.x;
    }

    /// Finds the first occurrence of a character in the grid.
    ///
    /// * `needle` - The character to search for.
    /// Returns the 1D index of the character, or `null` if not found.
    pub fn getChar(self: *const Self, needle: u8) ?usize {
        for (self.grid_string, 0..) |c, i| {
            if (needle == c) {
                return i;
            }
        }
        return null;
    }

    /// Calculates the index of the adjacent cell in a given direction.
    ///
    /// * `i` - The starting index.
    /// * `dir` - The direction to move in.
    /// Returns the index of the adjacent cell, or `null` if the move is out of bounds.
    pub fn checkDirection(self: *const Self, i: usize, dir: Direction) ?usize {
        var xy = self.getXY(i);
        switch (dir) {
            .N => {
                if (xy.y > 0) xy.y -= 1 else return null;
            },
            .S => {
                if (xy.y < self.height - 1) xy.y += 1 else return null;
            },
            .E => {
                if (xy.x < self.width - 2) xy.x += 1 else return null;
            },
            .W => {
                if (xy.x > 0) xy.x -= 1 else return null;
            },
            .NE => {
                if (xy.y > 0) xy.y -= 1 else return null;
                if (xy.x < self.width - 2) xy.x += 1 else return null;
            },
            .NW => {
                if (xy.y > 0) xy.y -= 1 else return null;
                if (xy.x > 0) xy.x -= 1 else return null;
            },
            .SE => {
                if (xy.y < self.height - 1) xy.y += 1 else return null;
                if (xy.x < self.width - 2) xy.x += 1 else return null;
            },
            .SW => {
                if (xy.y < self.height - 1) xy.y += 1 else return null;
                if (xy.x > 0) xy.x -= 1 else return null;
            },
        }
        return self.indexFromXY(xy);
    }
};

/// Represents the cardinal and diagonal directions.
pub const Direction = enum {
    N,
    S,
    E,
    W,
    NE,
    NW,
    SE,
    SW,
};

/// Represents a 2D coordinate.
pub const XY = struct {
    x: usize,
    y: usize,
};
