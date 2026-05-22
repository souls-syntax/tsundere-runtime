//! tsundere_runtime.zig The entry point for runtime to intitiate 
const baka = @import("baka");
const std = @import("std");
const tsun = @import("tsundere");


pub fn main(init: std.process.Init) !void {
    // Fuck zig so quick std change atleast keep prev apis usable bastards. fuck you.
    var it = init.minimal.args.iterate();
    _ = it.next(); 
    const path = it.next() orelse {
        std.debug.print("usage: tsundere <app.baka>\n", .{});
        return;
    };
    const cwd = std.Io.Dir.cwd();
    const fd = try cwd.openFile(init.io, path, .{});

    const stat = try fd.stat(init.io);
    const file_size = stat.size;

    const binary = try std.posix.mmap(
        null, 
        @intCast(file_size), 
        .{ .READ = true, .EXEC = true },
        .{ .TYPE = .PRIVATE }, 
        fd.handle, 
        0
    );
    try tsun.load_binaries_and_run(binary);
}
