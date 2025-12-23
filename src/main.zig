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

    while (true) {
        try stdout.writeAll("List of database actions: \n");
        try stdout.writeAll("1. Create a database \n");
        try stdout.writeAll("2. Load a database \n");
        try stdout.writeAll("-1. End session \n");
        try stdout.writeAll("Pick your action: ");
        try stdout.flush();

        const str_optional = try stdin.takeDelimiter('\n');
        const str = str_optional orelse break;

        if (str.len != 1) {
            break;
        }

        var buffer: [1024]u8 = undefined;
        var fw_buffer: [1024]u8 = undefined;
        var file_reader_temp: ?std.fs.File.Reader = undefined;
        var file_writer_temp: ?std.fs.File.Writer = undefined;
        var db_optional: ?[]u8 = undefined;

        switch (str[0]) {
            '1' => {
                try stdout.writeAll("name your database: ");
                try stdout.flush();

                db_optional = try stdin.takeDelimiter('\n');
                const db_string = db_optional orelse break;

                const file = try std.fs.cwd().createFile(
                    db_string,
                    .{
                        .read = true,
                    },
                );
                file.close();

                var file_tmp: std.fs.File = try std.fs.cwd().openFile(db_string, .{ .mode = .read_write });
                file_reader_temp = file_tmp.reader(&buffer);
                file_writer_temp = file_tmp.writer(&fw_buffer);
            },
            '2' => {
                try stdout.writeAll("pick your database: ");
                try stdout.flush();

                db_optional = try stdin.takeDelimiter('\n');
                const db_string = db_optional orelse break;

                var file_tmp: std.fs.File = try std.fs.cwd().openFile(db_string, .{ .mode = .read_write });
                file_reader_temp = file_tmp.reader(&buffer);
                file_writer_temp = file_tmp.writer(&fw_buffer);
            },
            else => {
                try stdout.writeAll("That action doesn't exist!\n");
                try stdout.flush();
            },
        }

        const file_reader = file_reader_temp orelse break;
        _ = file_reader;
        const file_writer = file_writer_temp orelse break;
        _ = file_writer;
        const selected_db_string = db_optional orelse break;

        var cur_index: u32 = 0;
        var cur_max: u32 = 16;
        var books = try allocator.alloc(Book, cur_max);

        while (true) {
            try stdout.print("Current Selected DB: {s}\n", .{selected_db_string});
            try stdout.writeAll("List of Actions: \n");
            try stdout.writeAll("1. Add a book \n");
            try stdout.writeAll("2. Update a book \n");
            try stdout.writeAll("3. Delete a book \n");
            try stdout.writeAll("4. Save \n");
            try stdout.writeAll("-1. End database session \n");

            try stdout.writeAll("\n");
            try stdout.writeAll("Pick your action: ");
            try stdout.flush();

            const str2_optional = try stdin.takeDelimiter('\n');
            const str2 = str2_optional orelse break;

            if (str2.len != 1) {
                break;
            }

            switch (str2[0]) {
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
                '4' => {},
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
    }

    try stdout.writeAll("Thank you for using Wanshitong!.\n");
    try stdout.flush();
}
