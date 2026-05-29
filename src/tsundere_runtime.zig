//! tsundere_runtime.zig The entry point for runtime to intitiate 
const baka = @import("baka");
const std = @import("std");
const loader = @import("loader");
const elf = @import("elf");
const os = @import("os");

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

    const binary = try os.os_mmap(
        null, 
        @intCast(file_size), 
        .{ .READ = true },
        .{ .TYPE = .PRIVATE }, 
        fd.handle, 
        0
    );
    
    const page_size = std.heap.pageSize();
    const text_shdr = try elf.get_a_header(binary, ".text");
    const text_start = std.mem.alignBackward(usize, @as(usize, text_shdr.sh_offset), page_size);
    const text_end = std.mem.alignForward(usize, @as(usize, text_shdr.sh_offset + text_shdr.sh_size) , page_size);
    try os.os_mprotect(
            binary.ptr + text_start,
            text_end - text_start,
            .{ .READ = true, .EXEC = true }
        );
    try loader.load_binaries_and_run(binary);
}
