//! Rendering text and glyphs
//! https://cairographics.org/manual/cairo-text.html
const std = @import("std");
const c = @import("../c.zig");
const Error = @import("../errors.zig").Error;

// TODO: don't use this module. It doesn't work. c.cairo_glyph_allocate()
// returns an unnamed C struct and I don't know how to store it in a zig struct
// and pass it around.
// https://github.com/ziglang/zig/issues/4738
// https://github.com/ziglang/zig/pull/4973

pub const Glyph = struct {
    ptr: *GlyphT,
    // c_ptr: *struct_CAIRO_GLYPH_T,

    const Self = @This();

    /// https://cairographics.org/manual/cairo-text.html#cairo-glyph-allocate
    pub fn allocate(num_glyphs: usize) !Self {
        std.debug.print("allocate memory for {} glyphs\n", .{num_glyphs});
        var c_ptr = c.cairo_glyph_allocate(@intCast(c_int, num_glyphs));
        if (c_ptr == null) return Error.NoMemory;
        // std.debug.print("INFO {}\n", .{@typeInfo(@TypeOf(c_ptr))});
        // std.debug.print("SIZE {}\n", .{@sizeOf(@TypeOf(c_ptr))});
        // std.debug.print("NAME {}\n", .{@typeName(@TypeOf(c_ptr))});
        var ptr = @ptrCast(*GlyphT, c_ptr);
        // return Self{ .c_ptr = c_ptr };
        return Self{ .ptr = ptr };
    }
};

pub const GlyphT = extern struct {
    index: usize,
    x: f64,
    y: f64,
};

/// https://cairographics.org/manual/cairo-text.html#cairo-glyph-t
pub const struct_CAIRO_GLYPH_T = extern struct {
    index: c_ulong,
    x: f64,
    y: f64,
};
