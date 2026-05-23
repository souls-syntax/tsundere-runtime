const std = @import("std");
const builtin = @import("builtin");
const baka = @import("baka");


const PROT = std.posix.PROT;
const page_size_min = std.heap.page_size_min; 
const MAP = std.posix.MAP;
const fd_t = std.posix.fd_t;
const MMapError = std.posix.MMapError;

pub fn interface_mprotect(address: [*]const u8, length: usize, protection: PROT) !void {

    if ( builtin.target.os.tag  == .linux) {
        _ = std.os.linux.mprotect(@alignCast(address), length, protection);
        return;
    } else if (builtin.target.os.tag == .windows) {
        return baka.BakaErr.NotImplementedYet;
    }

    return baka.BakaErr.NotImplementedYet;
}

pub fn interface_mmap(ptr: ?[*]align(page_size_min) u8, length: usize, prot: PROT, flags: MAP, fd: fd_t, offset: u64) baka.BakaErr![]align(page_size_min) u8 {
    if (builtin.target.os.tag == .linux) {
        return std.posix.mmap(ptr, length, prot, flags, fd, offset) catch return baka.BakaErr.MMapFailed;
    }
    return baka.BakaErr.MMapFailed;
}
