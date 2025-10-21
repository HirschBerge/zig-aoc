run day:
        zig build day{{day}}

test day:
        zig build test_day{{day}} --summary all
