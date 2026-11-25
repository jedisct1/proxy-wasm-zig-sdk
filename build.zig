const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding } });
    const optimize = b.standardOptimizeOption(.{});

    const sdk = b.addModule("proxy-wasm-zig-sdk", .{ .root_source_file = b.path("lib/lib.zig") });

    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("example/example.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.addImport("proxy-wasm-zig-sdk", sdk);

    exe.rdynamic = true;
    exe.entry = .disabled;
    b.installArtifact(exe);

    const exe_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("example/e2e_test.zig"),
            .target = b.graph.host,
            .optimize = optimize,
        }),
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    run_exe_unit_tests.step.dependOn(b.getInstallStep());

    const test_step = b.step("test", "Run End-to-End test with Envoy proxy");
    test_step.dependOn(&run_exe_unit_tests.step);
    const e2e_step = b.step("e2e", "Run End-to-End test with Envoy proxy");
    e2e_step.dependOn(test_step);
}
