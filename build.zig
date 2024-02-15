const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .wasm32, .os_tag = .wasi } });
    const optimize = b.standardOptimizeOption(.{});

    const sdk = b.addModule("proxy-wasm-zig-sdk", .{ .root_source_file = .{ .path = "lib/lib.zig" } });

    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{ .path = "example/example.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("proxy-wasm-zig-sdk", sdk);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "example/e2e_test.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run End-to-End test with Envoy proxy");
    test_step.dependOn(&run_cmd.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
