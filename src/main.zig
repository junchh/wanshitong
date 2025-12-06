const std = @import("std");
var stdin_buffer: [1024]u8 = undefined;
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
const stdin = &stdin_reader.interface;
const stdout = &stdout_writer.interface;

const Book = struct {
    title: []u8,
    description: []u8,
};

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
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
    try stdout.writeAll("2. Update a book \n");
    try stdout.writeAll("3. Delete a book \n");
    try stdout.writeAll("4. Load from database \n");
    try stdout.writeAll("5. Save to database \n");
    try stdout.writeAll("-1. End session \n");

    try stdout.writeAll("\n");
    try stdout.flush();

    const books = try allocator.alloc(Book, 16);
    var cur_index: u16 = 0;

    while (true) {
        try stdout.writeAll("Pick your action: ");
        try stdout.flush();

        const str_optional = try stdin.takeDelimiter('\n');
        const str = str_optional orelse break;

        if (str.len != 1) {
            break;
        }

        switch (str[0]) {
            '1' => {
                try stdout.writeAll("Enter the title: ");
                try stdout.flush();

                const name_optional = try stdin.takeDelimiter('\n');
                const name = try allocator.dupe(u8, name_optional orelse return);

                try stdout.writeAll("Enter the description: ");
                try stdout.flush();

                const description_optional = try stdin.takeDelimiter('\n');
                const description = try allocator.dupe(u8, description_optional orelse return);

                books[cur_index] = .{ .title = name, .description = description };
                cur_index += 1;
            },
            else => {
                try stdout.writeAll("That action doesn't exist!\n");
                try stdout.flush();
            },
        }
    }

    var i: u16 = 0;
    while (i < cur_index) {
        try stdout.print("Book number: {d}\ntitle: {s}\ndescription: {s}\n", .{ (i + 1), books[i].title, books[i].description });
        try stdout.flush();
        i += 1;
    }

    i = 0;
    while (i < cur_index) {
        allocator.free(books[i].title);
        allocator.free(books[i].description);
        i += 1;
    }

    allocator.free(books);

    try stdout.writeAll("Thank you for using Wanshitong!.\n");
    try stdout.flush();
}
