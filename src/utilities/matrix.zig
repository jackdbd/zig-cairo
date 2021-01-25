//! Generic matrix operations
const std = @import("std");
const c = @import("../c.zig");

// I guess this struct is not really necessary, since we can use
// allocator.create() on the original C struct.
const MatrixT = extern struct {
    xx: f64,
    yx: f64,
    xy: f64,
    yy: f64,
    x0: f64,
    y0: f64,
};

pub const Matrix = struct {
    allocator: *std.mem.Allocator,
    /// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-t
    c_ptr: *c.struct__cairo_matrix,

    const Self = @This();

    pub fn destroy(self: *Self) void {
        self.allocator.destroy(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-init-identity
    pub fn identity(self: *Self) void {
        c.cairo_matrix_init_identity(self.c_ptr);
    }

    /// Initialize a matrix. The calles owns the memory and should call destroy
    /// when the matrix is no longer needed.
    /// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-init
    pub fn init(allocator: *std.mem.Allocator, xx: f64, yx: f64, xy: f64, yy: f64, x0: f64, y0: f64) !Self {
        // const ptr = try allocator.create(MatrixT);
        // const c_ptr = @ptrCast(*c.struct__cairo_matrix, ptr);
        const c_ptr = try allocator.create(c.struct__cairo_matrix);
        c.cairo_matrix_init(c_ptr, xx, yx, xy, yy, x0, y0);
        return Self{ .allocator = allocator, .c_ptr = c_ptr };
    }

    /// Initialize a matrix to a transformation that scales by sx and sy in the
    /// X and Y dimensions, respectively. The calles owns the memory and should
    /// call destroy when the matrix is no longer needed.
    /// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-init-scale
    pub fn initScale(allocator: *std.mem.Allocator, sx: f64, sy: f64) !Self {
        const c_ptr = try allocator.create(c.struct__cairo_matrix);
        c.cairo_matrix_init_scale(c_ptr, sx, sy);
        return Self{ .allocator = allocator, .c_ptr = c_ptr };
    }

    /// https://cairographics.org/manual/cairo-cairo-matrix-t.html#cairo-matrix-scale
    pub fn scale(self: *Self, sx: f64, sy: f64) void {
        c.cairo_matrix_scale(self.c_ptr, sx, sy);
    }
};
