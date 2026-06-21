const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const stb_image_write = b.addTranslateC(.{
        .root_source_file = b.path("c/stb_image_write.h"),
        .target = target,
        .optimize = optimize,
    });

    const stb_truetype = b.addTranslateC(.{
        .root_source_file = b.path("c/stb_truetype.h"),
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("zstb", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "stb_image_write", .module = stb_image_write.createModule() },
            .{ .name = "stb_truetype", .module = stb_truetype.createModule() },
        },
    });

    mod.addIncludePath(b.path("c"));
    mod.addCSourceFile(.{ .file = b.path("c/stb.c"), .flags = &.{} });
    mod.link_libc = true;

    const lib = b.addLibrary(.{
        .name = "zstb",
        .root_module = mod,
    });

    b.installArtifact(lib);
}
