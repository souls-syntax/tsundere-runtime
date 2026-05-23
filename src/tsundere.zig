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

// pub const BakaElfSymbol = extern struct {
//     st_name:  Elf64_Word,   // index into .strtab
//     st_info:  u8,           // type + binding
//     st_other: u8,           // visibility
//     st_shndx: Elf64_Half,   // section index
//     st_value: Elf64_Off,    // address / offset
//     st_size:  u64,
// };

// pub const BakaElfSection = extern struct {
//     sh_name      : Elf64_Word,   // Section name (string tbl index)
//     sh_type      : Elf64_Word,   // Section type
//     sh_flags     : Elf64_Xword,  // Section flags
//     sh_addr      : Elf64_Addr,   // Section virtual addr at execution
//     sh_offset    : Elf64_Off,    // Section file offset
//     sh_size      : Elf64_Xword,  // Section size in bytes
//     sh_link      : Elf64_Word,   // Link to another section
//     sh_info      : Elf64_Word,   // Additional section information
//     sh_addralign : Elf64_Xword,  // Section alignment
//     sh_entsize   : Elf64_Xword,  // Entry size if section holds table
// };
//
pub fn load_binaries_and_run(binary : []u8) !void {
    var header : *const baka.BakaHeader = @ptrCast(@alignCast(binary.ptr));
    var symbol_baka_main : ?*const baka.BakaElfSymbol = null;
    var symsh_offset : ?usize = null;
    if (header.magic_number != BAKA_MAGIC) {
        if (try elf.is_elf(binary)) {
            
            const baka_shdr = try elf.get_a_header(binary, ".baka_header");
            const baka_data = binary[baka_shdr.sh_offset .. baka_shdr.sh_offset + baka_shdr.sh_size];
            
            header = @ptrCast(@alignCast(baka_data.ptr));
            symbol_baka_main = try elf.get_the_symbol(binary, "baka_main");

            const sym = symbol_baka_main orelse return baka.BakaErr.SymbolNotFound;
            const text_shdr = try elf.get_section_by_index(binary, sym.st_shndx);

            // st_value gives virtual address hence to calculate the file offset we do sh_offset + (st_value - sh_addr)
            symsh_offset = @as(usize, text_shdr.sh_offset) + @as(usize, sym.st_value) - @as(usize, text_shdr.sh_addr);
        
        } else {
            return baka.BakaErr.WrongMagicNumber;
        }
    
    } else if (header.magic_number == BAKA_MAGIC) {
        header = @ptrCast(@alignCast(binary.ptr));
        symsh_offset = header.entry_offset;
    }

    if ( header.version != BAKA_VERSION ) return baka.BakaErr.StaleVersion;
    
    const offset = symsh_offset orelse return baka.BakaErr.SymbolNotFound;
    const entry_fn = @as(
        *const fn(*const baka.API) callconv(.c)  void,
        @ptrCast(@alignCast(binary.ptr + offset))
    );
    
    const api = baka.API {
        .text_render = &tsun_text_render,
    };
    entry_fn(&api);
}
