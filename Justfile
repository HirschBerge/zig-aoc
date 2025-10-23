run day:
        zig build day{{day}}

test day:
        zig build test_day{{day}} --summary all
all:
        zig build run_all
data day:
        cat ./src/data/day{{day}}.txt
