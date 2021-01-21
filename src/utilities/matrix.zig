//! Generic matrix operations
//! https://cairographics.org/manual/cairo-cairo-matrix-t.html
const std = @import("std");
const c = @import("../c.zig");

/// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-t
pub const MatrixT = extern struct {
    xx: f64,
    yx: f64,
    xy: f64,
    yy: f64,
    x0: f64,
    y0: f64,
};

pub const Matrix = struct {
    matrix: *c.struct__cairo_matrix,

    const Self = @This();

    /// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-init
    pub fn init(allocator: *std.mem.Allocator, xx: f64, yx: f64, xy: f64, yy: f64, x0: f64, y0: f64) !Self {
        const ptr = try allocator.create(MatrixT);
        var matrix = @ptrCast(*c.struct__cairo_matrix, ptr);
        c.cairo_matrix_init(matrix, xx, yx, xy, yy, x0, y0);
        return Self{ .matrix = matrix };
    }

    /// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-init-scale
    pub fn initScale(allocator: *std.mem.Allocator, sx: f64, sy: f64) !Self {
        const ptr = try allocator.create(MatrixT);
        var matrix = @ptrCast(*c.struct__cairo_matrix, ptr);
        c.cairo_matrix_init_scale(matrix, sx, sy);
        return Self{ .matrix = matrix };
    }

    /// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-scale
    pub fn scale(self: *Self, sx: f64, sy: f64) void {
        c.cairo_matrix_scale(self.matrix, sx, sy);
    }
};
