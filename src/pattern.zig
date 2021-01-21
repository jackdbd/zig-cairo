//! Cairo Patterns
//! https://cairographics.org/manual/cairo-cairo-pattern-t.html
const std = @import("std");
const c = @import("c.zig");
const enums = @import("enums.zig");
const Error = @import("errors.zig").Error;
const Surface = @import("surfaces/surfaces.zig").Surface;
const Matrix = @import("utilities/matrix.zig").Matrix;
const MatrixT = @import("utilities/matrix.zig").MatrixT;

/// Possible return values for cairo_pattern_status ()
/// https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-status
const Status = enum {
    Success = c.CAIRO_STATUS_SUCCESS, // 0
    NoMemory = c.CAIRO_STATUS_NO_MEMORY, // 1
    InvalidMatrix = c.CAIRO_STATUS_INVALID_MATRIX, // 5
    PatternTypeMismatch = c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH, // 14
    InvalidMeshConstruction = c.CAIRO_STATUS_INVALID_MESH_CONSTRUCTION, // 36
};

/// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-type-t
const PatternType = enum {
    Solid = c.CAIRO_PATTERN_TYPE_SOLID,
    Surface = c.CAIRO_PATTERN_TYPE_SURFACE,
    Linear = c.CAIRO_PATTERN_TYPE_LINEAR,
    Radial = c.CAIRO_PATTERN_TYPE_RADIAL,
    Mesh = c.CAIRO_PATTERN_TYPE_MESH,
    RasterSource = c.CAIRO_PATTERN_TYPE_RASTER_SOURCE,
};

pub const Pattern = struct {
    pattern: *c.struct__cairo_pattern,

    const Self = @This();

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-linear
    pub fn createLinear(x0: f64, y0: f64, x1: f64, y1: f64) !Self {
        var pattern = c.cairo_pattern_create_linear(x0, y0, x1, y1);
        try checkStatus(pattern);
        return Self{ .pattern = pattern.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-radial
    pub fn createRadial(cx0: f64, cy0: f64, radius0: f64, cx1: f64, cy1: f64, radius1: f64) !Self {
        var pattern = c.cairo_pattern_create_radial(cx0, cy0, radius0, cx1, cy1, radius1);
        try checkStatus(pattern);
        return Self{ .pattern = pattern.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-rgb
    pub fn createRgb(r: f64, g: f64, b: f64) !Self {
        var pattern = c.cairo_pattern_create_rgb(r, g, b);
        try checkStatus(pattern);
        return Self{ .pattern = pattern.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-rgba
    pub fn createRgba(r: f64, g: f64, b: f64, alpha: f64) !Self {
        var pattern = c.cairo_pattern_create_rgba(r, g, b, alpha);
        try checkStatus(pattern);
        return Self{ .pattern = pattern.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-for-surface
    pub fn createForSurface(surface: *Surface) !Self {
        var pattern = c.cairo_pattern_create_for_surface(surface.surface);
        try checkStatus(pattern);
        return Self{ .pattern = pattern.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-extend
    pub fn setExtend(self: *Self, extend: enums.Extend) void {
        c.cairo_pattern_set_extend(self.pattern, extend.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-matrix
    pub fn setMatrix(self: *Self, matrix: *Matrix) void {
        c.cairo_pattern_set_matrix(self.pattern, matrix.matrix);
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_pattern_destroy(self.pattern);
        // std.debug.print("cairo.Pattern {} destroyed\n", .{self});
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-add-color-stop-rgb
    pub fn addColorStopRgb(self: *Self, offset: f64, r: f64, g: f64, b: f64) void {
        c.cairo_pattern_add_color_stop_rgb(self.pattern, offset, r, g, b);
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-add-color-stop-rgba
    pub fn addColorStopRgba(self: *Self, offset: f64, r: f64, g: f64, b: f64, alpha: f64) void {
        c.cairo_pattern_add_color_stop_rgba(self.pattern, offset, r, g, b, alpha);
    }
};

/// Check whether an error has previously occurred for this pattern.
/// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-status
fn checkStatus(cairo_pattern: ?*c.struct__cairo_pattern) !void {
    if (cairo_pattern == null) {
        return Error.NoMemory;
    } else {
        const c_enum = c.cairo_pattern_status(cairo_pattern);
        const c_integer = @enumToInt(c_enum);
        // std.debug.print("c_enum: {}\n", .{c_enum});
        // std.debug.print("c_integer: {}\n", .{c_integer});
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {},
            c.CAIRO_STATUS_NO_MEMORY => Error.NoMemory,
            c.CAIRO_STATUS_INVALID_MATRIX => Error.InvalidMatrix,
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            c.CAIRO_STATUS_INVALID_MESH_CONSTRUCTION => Error.InvalidMeshConstruction,
            else => unreachable,
        };
    }
}
