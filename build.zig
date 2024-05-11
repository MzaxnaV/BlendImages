const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    }).artifact("raylib");

    const raygui_dep = b.dependency("raygui", .{});
    var raygui_step = b.addWriteFiles();
    // need a c file https://github.com/ziglang/zig/issues/19423
    const raygui_c = raygui_step.add("raygui.c", "#define RAYGUI_IMPLEMENTATION\n#include \"raygui.h\"\n");

    const exe = b.addExecutable(.{
        .name = "BlendImages",

        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.step.dependOn(&raygui_step.step);
    exe.addCSourceFile(.{ .file = raygui_c, .flags = &.{""} });
    exe.addIncludePath(raygui_dep.path("src"));
    exe.linkLibrary(raylib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
