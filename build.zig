const std = @import("std");

pub fn buildExe(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const exe = b.addExecutable(.{
        .name = "ze-forge",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    const abi = (std.zig.system.resolveTargetQuery(target.query) catch unreachable).abi;
    exe.linkLibC();
    if (abi != .msvc) {
        exe.linkLibCpp();
    }

    {
        const run_cmd = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}

pub fn buildLib(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const lib_zf = b.addStaticLibrary(.{
        .name = "lib_zf",
        .target = target,
        .optimize = optimize,
    });

    lib_zf.linkLibC();
    if (target.result.abi != .msvc) {
        lib_zf.linkLibCpp();
    }

    const cflags = &.{
        "-DD3D12_AGILITY_SDK=1",
        "-DD3D12_AGILITY_SDK_VERSION=715",
        // "-DEXTERNAL_RENDERER_CONFIG_FILEPATH=\"external/Examples_3/Sandbox/Code/ExternalRendererConfig.h\"",
    };

    lib_zf.addCSourceFiles(.{
        .files = &.{
            "src/single_header_wrapper.cpp",
            "external/The-Forge/Common_3/Graphics/GraphicsConfig.cpp",
            "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12_cxx.cpp",
            "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12.c",
            "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12Hooks.c",
            // "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12Hooks.cpp",
            "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12Raytracing.c",
        },
        .flags = cflags,
    });

    b.installArtifact(lib_zf);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    buildLib(b, target, optimize);
    // buildExe(b, target, optimize);
}
