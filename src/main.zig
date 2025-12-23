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
        try stdout.writeAll("Pick your action database action: ");
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
        const file_writer = file_writer_temp orelse break;
        const selected_db_string = db_optional orelse break;

        const book_file_read = try file_reader.file.readToEndAlloc(allocator, 10 * 1024 * 1024);

        const len_existing = book_file_read.len / 384;

        var cur_index: u64 = 0;
        var cur_max: u64 = 16;
        var books = try allocator.alloc(Book, cur_max);

        if (len_existing != 0) {
            cur_index = len_existing;
            cur_max = len_existing * 2;
            books = try allocator.realloc(books, cur_max);

            {
                var i: u64 = 0;
                while (i < book_file_read.len) : (i += 384) {
                    var len_title: u64 = 0;
                    var len_description: u64 = 0;

                    var k: u64 = 0;
                    while (k < 384) : (k += 1) {
                        if (k < 128) {
                            if (book_file_read[k] != 0) {
                                len_title += 1;
                            }
                        } else {
                            if (book_file_read[k] != 0) {
                                len_description += 1;
                            }
                        }
                    }
                    const title = try allocator.alloc(u8, len_title);
                    const description = try allocator.alloc(u8, len_description);
                    k = 0;
                    while (k < 384) : (k += 1) {
                        if (k < 128) {
                            if (book_file_read[k] != 0) {
                                title[k] = book_file_read[k];
                            }
                        } else {
                            if (book_file_read[k] != 0) {
                                description[k - 128] = book_file_read[k];
                            }
                        }
                    }

                    books[i / 384] = .{ .title = title, .description = description };
                }
            }
        }

        while (true) {
            try stdout.print("Current Selected DB: {s}\n", .{selected_db_string});

            try stdout.flush();
            try stdout.writeAll("List of Actions: \n");
            try stdout.writeAll("1. Add a book \n");
            try stdout.writeAll("2. Update a book \n");
            try stdout.writeAll("3. Delete a book \n");
            try stdout.writeAll("4. Save \n");
            try stdout.writeAll("5. Print books \n");
            try stdout.writeAll("-1. Disconnect with database \n");

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
                '4' => {
                    try file_writer.file.seekTo(0);
                    var book_file = try allocator.alloc(u8, cur_index * 384);
                    {
                        var i: u16 = 0;
                        while (i < cur_index) : (i += 1) {
                            var j: u64 = i * 384;
                            while (j < (i + 1) * 384) : (j += 1) {
                                // i = 0
                                // j = 0 -> 383
                                // i = 1
                                // j = 384 -> 767
                                const norm_j = j % 384;
                                if (norm_j < books[i].title.len) {
                                    book_file[j] = books[i].title[norm_j];
                                } else if (norm_j >= 128 and norm_j < 128 + books[i].description.len) {
                                    book_file[j] = books[i].description[norm_j - 128];
                                } else {
                                    book_file[j] = 0;
                                }
                            }
                        }
                        try file_writer.file.writeAll(book_file);
                    }
                    allocator.free(book_file);
                },
                '5' => {
                    try stdout.print("Number of books: {d}\n", .{cur_index});
                    try stdout.flush();

                    {
                        var i: u16 = 0;
                        while (i < cur_index) {
                            try stdout.print("Book number: {d}\ntitle: {s}\ndescription: {s}\n", .{ (i + 1), books[i].title, books[i].description });
                            try stdout.flush();
                            i += 1;
                        }
                    }
                },
                else => {
                    try stdout.writeAll("That action doesn't exist!\n");
                    try stdout.flush();
                },
            }
        }

        // {
        //     var i: u16 = 0;
        //     while (i < cur_index) {
        //         allocator.free(books[i].title);
        //         allocator.free(books[i].description);
        //         i += 1;
        //     }
        //
        //     allocator.free(books);
        // }
    }

    try stdout.writeAll("Thank you for using Wanshitong!.\n");
    try stdout.flush();
}
