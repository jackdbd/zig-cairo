const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const Mode = builtin.Mode;

const EXAMPLES = [_][]const u8{
    "arc",
    "arc_negative",
    "bezier",
    "cairoscript",
    "clip",
    "clip_image",
    "compositing",
    "curve_rectangle",
    "curve_to",
    "dash",
    "ellipse",
    "fill_and_stroke2",
    "fill_style",
    "glyphs",
    "gradient",
    "grid",
    "group",
    "image",
    "image_pattern",
    "mask",
    "multi_segment_caps",
    "pango_simple",
    "pythagoras_tree",
    "rounded_rectangle",
    "save_and_restore",
    "set_line_cap",
    "set_line_join",
    "sierpinski",
    "singular",
    "spiral",
    "spirograph",
    "surface_image",
    "surface_pdf",
    "surface_svg",
    "surface_xcb",
    "text",
    "text_align_center",
    "text_extents",
    "three_phases",
};

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const test_all_modes_step = b.step("test", "Run all tests in all modes.");
    inline for ([_]Mode{ Mode.Debug, Mode.ReleaseFast, Mode.ReleaseSafe, Mode.ReleaseSmall }) |test_mode| {
        const mode_str = comptime modeToString(test_mode);
        const name = "test-" ++ mode_str;
        const desc = "Run all tests in " ++ mode_str ++ " mode.";
        const tests = b.addTest("src/pangocairo.zig");
        tests.setBuildMode(test_mode);
        tests.setTarget(target);
        tests.setNamePrefix(mode_str ++ " ");
        tests.linkLibC();
        tests.linkSystemLibrary("xcb");
        tests.linkSystemLibrary("pango");
        tests.linkSystemLibrary("cairo");
        tests.linkSystemLibrary("pangocairo");
        const test_step = b.step(name, desc);
        test_step.dependOn(&tests.step);
        test_all_modes_step.dependOn(test_step);
    }

    // const examples_step = b.step("examples", "Build all examples");
    inline for (EXAMPLES) |name| {
        const example = b.addExecutable(name, "examples" ++ std.fs.path.sep_str ++ name ++ ".zig");
        example.addPackage(.{ .name = "cairo", .path = "src/cairo.zig" });
        if (shouldIncludeXcb(name)) {
            example.addPackage(.{ .name = "xcb", .path = "src/xcb.zig" });
        }
        if (shouldIncludePango(name)) {
            example.addPackage(.{ .name = "pangocairo", .path = "src/pangocairo.zig" });
        }
        example.setBuildMode(mode);
        example.setTarget(target);
        example.linkLibC();
        example.linkSystemLibrary("cairo");
        if (shouldIncludeXcb(name)) {
            example.linkSystemLibrary("xcb");
        }
        example.linkSystemLibrary("pangocairo");
        // example.install(); // uncomment to build ALL examples (it takes ~2 minutes)
        // examples_step.dependOn(&example.step);

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

fn shouldIncludePango(comptime name: []const u8) bool {
    var b = false;
    if (name.len > 6) {
        b = std.mem.eql(u8, name[0..6], "pango_");
    }
    return b;
}

fn shouldIncludeXcb(comptime name: []const u8) bool {
    return std.mem.eql(u8, name, "surface_xcb");
}
