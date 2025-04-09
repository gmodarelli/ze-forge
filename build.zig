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
    const ze_forge_c_cpp = b.addStaticLibrary(.{
        .name = "ze_forge_c_cpp",
        .target = target,
        .optimize = optimize,
    });

    ze_forge_c_cpp.linkLibC();
    if (target.result.abi != .msvc) {
        ze_forge_c_cpp.linkLibCpp();
    }

    const cflags = &.{
        "-DTIDES",
        "-DD3D12_AGILITY_SDK=1",
        "-DD3D12_AGILITY_SDK_VERSION=715",
    };

    ze_forge_c_cpp.addCSourceFiles(.{
        .files = &.{
            // Single header libraries
            "src/single_header_wrapper.cpp",

            // The-forge graphics
            "external/The-Forge/Common_3/Graphics/GraphicsConfig.cpp",
            "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12_cxx.cpp",
            "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12.c",
            "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12Hooks.c",
            "external/The-Forge/Common_3/Graphics/Direct3D12/Direct3D12Raytracing.c",
            // Glue
            "external/The-Forge/Common_3/Graphics/Interfaces/IGraphics_glue.cpp",
            "external/The-Forge/Common_3/Graphics/Interfaces/IRay_glue.cpp",

            // TIDES
            "external/The-Forge/Common_3/Tides/WindowsFileSystem.c",
            "external/The-Forge/Common_3/Tides/WindowsLog.c",
            "external/The-Forge/Common_3/Tides/WindowsMemory.c",
            "external/The-Forge/Common_3/Tides/WindowsThread.c",
        },
        .flags = cflags,
    });

    b.installArtifact(ze_forge_c_cpp);

    var ze_forge = b.addModule("ze_forge", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    ze_forge.linkLibrary(ze_forge_c_cpp);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    buildLib(b, target, optimize);
    // buildExe(b, target, optimize);
}
