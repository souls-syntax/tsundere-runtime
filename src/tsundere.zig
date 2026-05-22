//! tsundere.zig Contains the implementation for API functions defined

const std = @import("std");
const baka = @import("baka");
const elf = @import("elf");

const BAKA_MAGIC: u32 = 0x62616B61;
const BAKA_VERSION : u32 = 1;

const print = std.debug.print;

fn tsun_text_render(x: i32, y: i32, text: [*:0]const u8) callconv(.c) void {
    std.debug.print("rendering at {}, {},: {s}\n", .{x, y, text});
} 

pub fn load_binaries_and_run(binary : []u8) !void {
    var header : *const baka.BakaHeader = @ptrCast(@alignCast(binary.ptr));

    if (header.magic_number != BAKA_MAGIC) {
        if (try elf.is_elf(binary)) {
            const baka_shdr = try elf.get_baka_header(binary);
            const baka_data = binary[baka_shdr.sh_offset .. baka_shdr.sh_offset + baka_shdr.sh_size];
            header = @ptrCast(@alignCast(baka_data.ptr));
            // TODO: Implement symbol walk so we find baka_main or smt
            print("Ok it's ELF", .{});
            return baka.BakaErr.NotImplementedYet;
        } else {
            return baka.BakaErr.WrongMagicNumber;
        }
    }

    if ( header.version != BAKA_VERSION ) return baka.BakaErr.StaleVersion;
    
    const entry_fn = @as(
        *const fn(*const baka.API) callconv(.c)  void,
        @ptrCast(@alignCast(binary.ptr + header.entry_offset))
    );
    
    const api = baka.API {
        .text_render = &tsun_text_render,
    };
    entry_fn(&api);
}
