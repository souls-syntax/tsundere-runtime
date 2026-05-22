//! baka.zig The comman header file for the baka apps to include

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
    WrongsMagicNumber,
    StaleVersion,
    MemoryRequestDenied,
    FileUnreadable,
};

pub const API = extern struct {
    // TODO: Make a nice init thingie
    // don't know what would be here
    // When we have 2d renderer this init app will load that module i say.
    // baka_init: *const fn () void,

    text_render: *const fn(x: i32, y: i32, text: [*:0]const u8) callconv(.c) void,
};
