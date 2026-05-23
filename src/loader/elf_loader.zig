const baka = @import("baka");
const std = @import("std");

const ELF_MAGIC = [_]u8{0x7F, 'E', 'L', 'F'};
const ELF_VERSION = 1;

pub fn is_elf(binary : []u8) !bool {
    if (binary.len < @sizeOf(baka.BakaElfHeader)) {
        return baka.BakaErr.InvalidBinary;
    }
    const elf_header : *const baka.BakaElfHeader = @ptrCast(@alignCast(binary.ptr));

    return std.mem.eql(u8,ELF_MAGIC[0..], elf_header.e_ident[0..4]);
}

pub fn get_a_header(binary : []u8, text : []const u8) !*const baka.BakaElfSection{
    // We get the elf header
    const ehdr: *const baka.BakaElfHeader = @ptrCast(@alignCast(binary.ptr));
    // we calculate the string section offset
    const shstrtab_off: usize = @intCast(ehdr.e_shoff + (ehdr.e_shstrndx  * ehdr.e_shentsize)); 

    if (shstrtab_off + @sizeOf(baka.BakaElfSection) > binary.len) return baka.BakaErr.InvalidBinary;
    // we jump there and typecase it to BakaElfSection
    const shstrtab_shdr: *const baka.BakaElfSection = @ptrCast(@alignCast(binary.ptr + shstrtab_off));
    // We get the data on the location where section is actually present
    const strtab: [*]const u8 = @ptrCast(binary.ptr + shstrtab_shdr.sh_offset);
    var i : usize = 0;
    while (i < ehdr.e_shnum) : ( i += 1 ) {
        const offset: usize = @as(usize, ehdr.e_shoff) + i * @as(usize, ehdr.e_shentsize);
        const shdr: *const baka.BakaElfSection = @ptrCast(@alignCast(binary.ptr + offset));
        const name = std.mem.sliceTo(strtab + @as(usize, shdr.sh_name), 0);
        if (std.mem.eql(u8, name , text)) { 
            return shdr;
        }
    }
    return baka.BakaErr.SectionNotFound;
}

pub fn get_the_symbol(binary : []u8, text : []const u8) !*const baka.BakaElfSymbol {
    
    var symtab_shdr : ?*const baka.BakaElfSection = null;
    var strtab_shdr : ?*const baka.BakaElfSection = null;
    
    symtab_shdr = get_a_header(binary, ".symtab") catch null;
    strtab_shdr = get_a_header(binary, ".strtab") catch null;

    const symtab = symtab_shdr orelse return baka.BakaErr.SectionNotFound;
    const strtab_sec = strtab_shdr orelse return baka.BakaErr.SectionNotFound;

    const strtab : [*]const u8 = @ptrCast(binary.ptr + strtab_sec.sh_offset);

    const sym_count = symtab.sh_size / @sizeOf(baka.BakaElfSymbol);
    
    var j: usize = 0;
    while( j < sym_count) : (j += 1) {
        const sym_off : usize = @as(usize, symtab.sh_offset) + j*@sizeOf(baka.BakaElfSymbol);
        const sym : *const baka.BakaElfSymbol = @ptrCast(@alignCast(binary.ptr + sym_off));
        const name = std.mem.sliceTo(strtab + @as(usize, sym.st_name), 0);
        if (std.mem.eql(u8, name, text)) {
            return sym;
        }
    }
    return baka.BakaErr.SymbolNotFound;
}

pub fn get_section_by_index(binary: []u8, index : u16) !*const baka.BakaElfSection {
    const ehdr: *const baka.BakaElfHeader = @ptrCast(@alignCast(binary.ptr));
    if( index > ehdr.e_shnum) return baka.BakaErr.InvalidBinary;
    const offset: usize = @as(usize, ehdr.e_shoff) + @as(usize, index) * @as(usize, ehdr.e_shentsize);
    if (offset + @sizeOf(baka.BakaElfSection) > binary.len) return baka.BakaErr.InvalidBinary;
    return @ptrCast(@alignCast(binary.ptr + offset));
}



