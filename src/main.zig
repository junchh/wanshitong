const std = @import("std");
var stdin_buffer: [1024]u8 = undefined;
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
const stdin = &stdin_reader.interface;
const stdout = &stdout_writer.interface;

const cwd = std.fs.cwd();

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

    const file_reader = try cwd.readFileAlloc(allocator, "database", 10 * 1024 * 1024);

    var cur_max: u32 = 16;
    var cur_index: u32 = 0;
    var books_optional: ?[]Book = undefined;
    if (file_reader.len == 0) {
        books_optional = try allocator.alloc(Book, cur_max);
    } else {
        const normalized_len: u32 = @truncate(file_reader.len);
        cur_index = normalized_len;
        cur_max *= cur_index;
        books_optional = try allocator.alloc(Book, cur_max);
        var i: u32 = 0;
        while (i < cur_index) {
            var buf_title = [_]u8{0} ** 128;
            var buf_description = [_]u8{0} ** 256;
            while (i % 384 != 128) {
                buf_title[i % 384] = file_reader.ptr[i];
                i += 1;
            }
            while (i % 384 != 0) {
                buf_description[(i % 384) - 128] = file_reader.ptr[i];
                i += 1;
            }
        }
    }

    var books = books_optional orelse return;

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

                if (cur_index == cur_max) {
                    try stdout.writeAll("Full!!!\n");
                    try stdout.flush();
                    cur_max *= 2;
                    books = try allocator.realloc(books, cur_max);
                }

                books[cur_index] = .{ .title = name, .description = description };

                cur_index += 1;
            },
            '2' => {
                try stdout.writeAll("Enter the title of the book you want to change: ");
                try stdout.flush();

                const name_optional = try stdin.takeDelimiter('\n');
                const name = try allocator.dupe(u8, name_optional orelse return);

                var idx_optional: ?u16 = null;
                var i: u16 = 0;
                while (i < cur_index) {
                    if (std.mem.eql(u8, books[i].title, name)) {
                        idx_optional = i;
                    }
                    i += 1;
                }

                const idx = idx_optional orelse return;

                try stdout.writeAll("Choose which one do you want to update: \n");
                try stdout.writeAll("1. title\n");
                try stdout.writeAll("2. description\n");
                try stdout.writeAll("Enter option: ");
                try stdout.flush();

                const type_optional = try stdin.takeDelimiter('\n');
                const option = type_optional orelse break;

                if (option[0] == '1') {
                    try stdout.writeAll("Enter new title: ");
                    try stdout.flush();
                    const title_optional = try stdin.takeDelimiter('\n');
                    const title = try allocator.dupe(u8, title_optional orelse return);

                    allocator.free(books[idx].title);
                    books[idx].title = title;
                } else {
                    try stdout.writeAll("Enter new description: ");
                    try stdout.flush();
                    const description_optional = try stdin.takeDelimiter('\n');
                    const description = try allocator.dupe(u8, description_optional orelse return);

                    allocator.free(books[idx].description);
                    books[idx].description = description;
                }
            },
            '3' => {
                try stdout.writeAll("Enter the title of the book you want to delete: ");
                try stdout.flush();

                const name_optional = try stdin.takeDelimiter('\n');
                const name = try allocator.dupe(u8, name_optional orelse return);

                var idx_optional: ?u16 = null;
                var i: u16 = 0;
                while (i < cur_index) {
                    if (std.mem.eql(u8, books[i].title, name)) {
                        idx_optional = i;
                    }
                    i += 1;
                }

                const idx = idx_optional orelse return;
                allocator.free(books[idx].title);
                allocator.free(books[idx].description);

                var idx_temp: u16 = idx;
                while (idx_temp + 1 < cur_index) {
                    books[idx_temp].title = books[idx_temp + 1].title;
                    books[idx_temp].description = books[idx_temp + 1].description;
                    idx_temp += 1;
                }

                cur_index -= 1;

                try stdout.writeAll("Book deleted!.\n");
                try stdout.flush();
            },
            '4' => {
                // var file_reader = try cwd.openFile("test.txt", .{ .mode = .read_only });
                // defer file_reader.close();
                //
                // var buf_file: [1024]u8 = undefined;
                // const len = try file_reader.read(&buf_file);
                //
                // try stdout.print("{d}\n", .{len});
                // {
                //     var idx: u16 = 0;
                //     while (idx < len) {
                //         try stdout.print("{d}\n", .{buf_file[idx]});
                //         idx += 1;
                //     }
                // }
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
