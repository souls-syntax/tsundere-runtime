//! baka.zig The comman header file for the baka apps to include

const std = @import("std");

pub const BakaHeader = extern struct {
    magic_number : u32,
    version : u32,
    memory_mb : u32,
    binary_size : u32,
    entry_offset : u32,
    name : [32:0] u8,
    padding : [12:0] u8, // So it becomes a nice 0x40 yay
};

pub const BakaErr = error{
    WrongMagicNumber,
    StaleVersion,
    MemoryRequestDenied,
    FileUnreadable,
    InvalidBinary,
    SectionNotFound,
    NotImplementedYet,
    SymbolNotFound,
};

// [ ELF Header ]
// [ Program Headers ]
// [ Sections/Data ]

/// Type for a 16-bit quantity.
const Elf32_Half = u16;
const Elf64_Half = u16;

/// Types for signed and unsigned 32-bit quantities.
const Elf32_Word  = u32;
const Elf32_Sword = i32;
const Elf64_Word  = u32;
const Elf64_Sword = i32;

/// Types for signed and unsigned 64-bit quantities.
const Elf32_Xword  = u64;
const Elf32_Sxword = i64;
const Elf64_Xword  = u64;
const Elf64_Sxword = i64;

/// Type of addresses.
const Elf32_Addr = u32;
const Elf64_Addr = u64;

/// Type of file offsets.
const Elf32_Off = u32;
const Elf64_Off = u64;

/// Type for section indices, which are 16-bit quantities.
const Elf32_Section = u16;
const Elf64_Section = u16;

/// Type for version symbol information.
const Elf32_Versym = Elf32_Half;
const Elf64_Versym = Elf64_Half;

pub const BakaElfHeader = extern struct {
    e_ident     : [16]u8,           // magic bytes is this 7F 45 4C 46
    e_type      : Elf64_Half,       // what kind of ELF is this? exec one read one or such thing
    e_machine   : Elf64_Half,       // which arch
    e_version   : Elf64_Word,       // default value 1
    e_entry     : Elf64_Addr,       // location where the app will start, basically address of baka_main
    e_phoff     : Elf64_Off,        // Offset in file where program headers begin this is byte offset INSIDE FILE. Not memory address.
    e_shoff     : Elf64_Off,        // offset to section header.
    e_flags     : Elf64_Word,       // Architecture specific flags.
    e_ehsize    : Elf64_Half,       // Size of This struct itself lol.
    e_phentsize : Elf64_Half,       // size of one program header entry. there would be many;
    e_phnum     : Elf64_Half,       // How many program header exits
    e_shentsize : Elf64_Half,       // Size of one section header
    e_shnum     : Elf64_Half,       // How many section exists
    e_shstrndx  : Elf64_Half,       // Index of section string table
};

comptime { std.debug.assert(@sizeOf(BakaElfHeader) == 64); }

// Special section indices
const SHN_UNDEF     : Elf64_Half = 0x0000; // Undefined section
const SHN_LORESERVE : Elf64_Half = 0xff00; // Start of reserved indices
const SHN_LOPROC    : Elf64_Half = 0xff00; // Start of processor-specific
const SHN_BEFORE    : Elf64_Half = 0xff00; // Order section before all others (Solaris)
const SHN_AFTER     : Elf64_Half = 0xff01; // Order section after all others (Solaris)
const SHN_HIPROC    : Elf64_Half = 0xff1f; // End of processor-specific
const SHN_LOOS      : Elf64_Half = 0xff20; // Start of OS-specific
const SHN_HIOS      : Elf64_Half = 0xff3f; // End of OS-specific
const SHN_ABS       : Elf64_Half = 0xfff1; // Associated symbol is absolute
const SHN_COMMON    : Elf64_Half = 0xfff2; // Associated symbol is common
const SHN_XINDEX    : Elf64_Half = 0xffff; // Index is in extra table
const SHN_HIRESERVE : Elf64_Half = 0xffff; // End of reserved indices

// Legal values for sh_type (section type)
const SHT_NULL          : Elf64_Word = 0;          // Section header table entry unused
const SHT_PROGBITS      : Elf64_Word = 1;          // Program data
const SHT_SYMTAB        : Elf64_Word = 2;          // Symbol table
const SHT_STRTAB        : Elf64_Word = 3;          // String table
const SHT_RELA          : Elf64_Word = 4;          // Relocation entries with addends
const SHT_HASH          : Elf64_Word = 5;          // Symbol hash table
const SHT_DYNAMIC       : Elf64_Word = 6;          // Dynamic linking information
const SHT_NOTE          : Elf64_Word = 7;          // Notes
const SHT_NOBITS        : Elf64_Word = 8;          // Program space with no data (bss)
const SHT_REL           : Elf64_Word = 9;          // Relocation entries, no addends
const SHT_SHLIB         : Elf64_Word = 10;         // Reserved
const SHT_DYNSYM        : Elf64_Word = 11;         // Dynamic linker symbol table
const SHT_INIT_ARRAY    : Elf64_Word = 14;         // Array of constructors
const SHT_FINI_ARRAY    : Elf64_Word = 15;         // Array of destructors
const SHT_PREINIT_ARRAY : Elf64_Word = 16;         // Array of pre-constructors
const SHT_GROUP         : Elf64_Word = 17;         // Section group
const SHT_SYMTAB_SHNDX  : Elf64_Word = 18;         // Extended section indeces
const SHT_NUM           : Elf64_Word = 19;         // Number of defined types
const SHT_LOOS          : Elf64_Word = 0x60000000; // Start OS-specific
const SHT_GNU_ATTRIBUTES: Elf64_Word = 0x6ffffff5; // Object attributes
const SHT_GNU_HASH      : Elf64_Word = 0x6ffffff6; // GNU-style hash table
const SHT_GNU_LIBLIST   : Elf64_Word = 0x6ffffff7; // Prelink library list
const SHT_CHECKSUM      : Elf64_Word = 0x6ffffff8; // Checksum for DSO content
const SHT_LOSUNW        : Elf64_Word = 0x6ffffffa; // Sun-specific low bound
const SHT_SUNW_move     : Elf64_Word = 0x6ffffffa;
const SHT_SUNW_COMDAT   : Elf64_Word = 0x6ffffffb;
const SHT_SUNW_syminfo  : Elf64_Word = 0x6ffffffc;
const SHT_GNU_verdef    : Elf64_Word = 0x6ffffffd; // Version definition section
const SHT_GNU_verneed   : Elf64_Word = 0x6ffffffe; // Version needs section
const SHT_GNU_versym    : Elf64_Word = 0x6fffffff; // Version symbol table
const SHT_HISUNW        : Elf64_Word = 0x6fffffff; // Sun-specific high bound
const SHT_HIOS          : Elf64_Word = 0x6fffffff; // End OS-specific type
const SHT_LOPROC        : Elf64_Word = 0x70000000; // Start of processor-specific
const SHT_HIPROC        : Elf64_Word = 0x7fffffff; // End of processor-specific
const SHT_LOUSER        : Elf64_Word = 0x80000000; // Start of application-specific
const SHT_HIUSER        : Elf64_Word = 0x8fffffff; // End of application-specific

// Legal values for sh_flags (section flags)
const SHF_WRITE            : Elf64_Xword = (1 << 0);  // Writable
const SHF_ALLOC            : Elf64_Xword = (1 << 1);  // Occupies memory during execution
const SHF_EXECINSTR        : Elf64_Xword = (1 << 2);  // Executable
const SHF_MERGE            : Elf64_Xword = (1 << 4);  // Might be merged
const SHF_STRINGS          : Elf64_Xword = (1 << 5);  // Contains nul-terminated strings
const SHF_INFO_LINK        : Elf64_Xword = (1 << 6);  // sh_info contains SHT index
const SHF_LINK_ORDER       : Elf64_Xword = (1 << 7);  // Preserve order after combining
const SHF_OS_NONCONFORMING : Elf64_Xword = (1 << 8);  // Non-standard OS specific handling required
const SHF_GROUP            : Elf64_Xword = (1 << 9);  // Section is member of a group
const SHF_TLS              : Elf64_Xword = (1 << 10); // Section hold thread-local data
const SHF_MASKOS           : Elf64_Xword = 0x0ff00000; // OS-specific
const SHF_MASKPROC         : Elf64_Xword = 0xf0000000; // Processor-specific
const SHF_ORDERED          : Elf64_Xword = (1 << 30); // Special ordering requirement (Solaris)
const SHF_EXCLUDE          : Elf64_Xword = (1 << 31); // Section is excluded unless referenced

pub const BakaElfSection = extern struct {
    sh_name      : Elf64_Word,   // Section name (string tbl index)
    sh_type      : Elf64_Word,   // Section type
    sh_flags     : Elf64_Xword,  // Section flags
    sh_addr      : Elf64_Addr,   // Section virtual addr at execution
    sh_offset    : Elf64_Off,    // Section file offset
    sh_size      : Elf64_Xword,  // Section size in bytes
    sh_link      : Elf64_Word,   // Link to another section
    sh_info      : Elf64_Word,   // Additional section information
    sh_addralign : Elf64_Xword,  // Section alignment
    sh_entsize   : Elf64_Xword,  // Entry size if section holds table
};

comptime { std.debug.assert(@sizeOf(BakaElfSection) == 64); }

pub const BakaElfSymbol = extern struct {
    st_name:  Elf64_Word,   // index into .strtab
    st_info:  u8,           // type + binding
    st_other: u8,           // visibility
    st_shndx: Elf64_Half,   // section index
    st_value: Elf64_Off,    // address / offset
    st_size:  u64,
};

pub const API = extern struct {
    // TODO: Make a nice init thingie
    // don't know what would be here
    // When we have 2d renderer this init app will load that module i say.
    // baka_init: *const fn () void,

    text_render: *const fn(x: i32, y: i32, text: [*:0]const u8) callconv(.c) void,
};
