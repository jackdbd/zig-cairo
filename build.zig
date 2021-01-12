const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const Mode = builtin.Mode;

const EXAMPLES = [_][]const u8{"image_example", "pdf_example", "svg_example", "xcb_example"};

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const test_all_modes_step = b.step("test", "Run all tests in all modes.");
    inline for ([_]Mode{ Mode.Debug, Mode.ReleaseFast, Mode.ReleaseSafe, Mode.ReleaseSmall }) |test_mode| {
        const mode_str = comptime modeToString(test_mode);
        const name = "test-" ++ mode_str;
        const desc = "Run all tests in " ++ mode_str ++ " mode.";
        const tests = b.addTest("src/cairo.zig");
        tests.setBuildMode(test_mode);
        tests.setTarget(target);
        tests.setNamePrefix(mode_str ++ " ");
        tests.linkLibC();
        tests.linkSystemLibrary("xcb");
        tests.linkSystemLibrary("cairo");
        const test_step = b.step(name, desc);
        test_step.dependOn(&tests.step);
        test_all_modes_step.dependOn(test_step);
    }

    const examples_step = b.step("examples", "Build examples");
    inline for (EXAMPLES) |name| {
        const example = b.addExecutable(name, "examples" ++ std.fs.path.sep_str ++ name ++ ".zig");
        example.addPackage(.{ .name = "cairo", .path = "src/cairo.zig" });
        if (std.mem.eql(u8, name, "xcb_example")) {
            example.addPackage(.{ .name = "xcb", .path = "src/xcb.zig" });
        }
        example.setBuildMode(mode);
        example.setTarget(target);
        example.linkLibC();
        example.linkSystemLibrary("cairo");
        if (std.mem.eql(u8, name, "xcb_example")) {
            example.linkSystemLibrary("xcb");
        }
        example.install();
        examples_step.dependOn(&example.step);

        const run_cmd = example.run();
        run_cmd.step.dependOn(b.getInstallStep());
        const desc = "Run the " ++ name ++ " example";
        const run_step = b.step(name, desc);
        run_step.dependOn(&run_cmd.step);
    }

    // b.default_step.dependOn(test_all_modes_step);
}

fn modeToString(mode: Mode) []const u8 {
    return switch (mode) {
        Mode.Debug => "debug",
        Mode.ReleaseFast => "release-fast",
        Mode.ReleaseSafe => "release-safe",
        Mode.ReleaseSmall => "release-small",
    };
}