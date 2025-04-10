const std = @import("std");

pub fn buildExe(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const exe = b.addExecutable(.{
        .name = "ze-forge-test",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const abi = (std.zig.system.resolveTargetQuery(target.query) catch unreachable).abi;
    exe.linkLibC();
    if (abi != .msvc) {
        exe.linkLibCpp();
    }

    // const ze_forge = b.dependency("ze_forge", .{
    //     .target = target,
    //     .optimize = optimize,
    // });
    // exe.root_module.addImport("ze_forge", ze_forge.module("root"));

    const ze_forge = b.dependency("ze_forge", .{});
    exe.root_module.addImport("ze_forge", ze_forge.module("ze_forge"));
    exe.linkLibrary(ze_forge.artifact("ze_forge_c_cpp"));

    b.installArtifact(exe);

    {
        const run_cmd = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    buildExe(b, target, optimize);
}
