const std = @import("std");
pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
    });

    const baka_mod = b.addModule("baka", .{
        .root_source_file = b.path("baka.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "app.baka",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "baka", .module = baka_mod },
            },
        }),
    });
    exe.setLinkerScript(b.path("linker.lds"));
    exe.entry = .disabled;
    b.installArtifact(exe);
}
