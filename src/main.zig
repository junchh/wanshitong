const std = @import("std");
var stdin_buffer: [1024]u8 = undefined;
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
const stdin = &stdin_reader.interface;
const stdout = &stdout_writer.interface;

pub fn main() !void {
    try stdout.writeAll("|--------------------------------------|\n");
    try stdout.writeAll("|                                      |\n");
    try stdout.writeAll("|                                      |\n");
    try stdout.writeAll("|              -Wanshitong-            |\n");
    try stdout.writeAll("|                                      |\n");
    try stdout.writeAll("|                                      |\n");
    try stdout.writeAll("|--------------------------------------|\n");
    try stdout.writeAll("\n");
    try stdout.writeAll("\n");
    try stdout.writeAll("List of Actions: \n");
    try stdout.writeAll("1. Add a book \n");
    try stdout.writeAll("\n");
    try stdout.flush();

    while (true) {
        try stdout.writeAll("Pick your action: ");
        try stdout.flush();

        const str = try stdin.takeDelimiterExclusive('\n');

        if (str.len != 1) {
            break;
        }

        switch (str[0]) {
            '1' => {
                try stdout.writeAll("You wanna add books\n");
                try stdout.flush();
            },
            else => {
                try stdout.writeAll("That action doesn't exist!\n");
                try stdout.flush();
            },
        }
    }

    try stdout.writeAll("Thank you for using Wanshitong!.\n");
    try stdout.flush();
}
