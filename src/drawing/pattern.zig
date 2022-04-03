//! Cairo Patterns.
const std = @import("std");
const c = @import("../c.zig");
const enums = @import("../enums.zig");
const PatternType = enums.PatternType;
const Extend = enums.Extend;
const Surface = @import("../surfaces/surface.zig").Surface;
const Matrix = @import("../utilities/matrix.zig").Matrix;
const Error = @import("../utilities/error_handling.zig").Error;

/// Wrapper for the Cairo cairo_pattern_t C struct.
pub const Pattern = struct {
    /// The original cairo_pattern_t C struct.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html
    c_ptr: *c.struct__cairo_pattern,

    const Self = @This();

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-add-color-stop-rgb
    pub fn addColorStopRgb(self: *Self, offset: f64, red: f64, green: f64, blue: f64) !void {
        c.cairo_pattern_add_color_stop_rgb(self.c_ptr, offset, red, green, blue);
        // If the pattern is not a gradient pattern, then the pattern will have
        // a status of CAIRO_STATUS_PATTERN_TYPE_MISMATCH.
        _ = try Pattern.status(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-add-color-stop-rgba
    pub fn addColorStopRgba(self: *Self, offset: f64, red: f64, green: f64, blue: f64, alpha: f64) !void {
        c.cairo_pattern_add_color_stop_rgba(self.c_ptr, offset, red, green, blue, alpha);
        // If the pattern is not a gradient pattern, then the pattern will have
        // a status of CAIRO_STATUS_PATTERN_TYPE_MISMATCH.
        _ = try Pattern.status(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-begin-patch
    pub fn beginPatch(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// Create a new pattern for the given surface. The caller owns the returned
    /// object and should call destroy() when finished with it.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-for-surface
    pub fn createForSurface(surface: *Surface) !Self {
        var c_ptr = c.cairo_pattern_create_for_surface(surface.c_ptr);
        // cairo_pattern_create_for_surface always returns a valid pointer, but
        // if an error occurred the pattern status will be set to an error.
        _ = try Pattern.status(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// Create a new linear gradient along the line defined by (x0, y0) and
    /// (x1, y1). The caller owns the returned object and should call destroy()
    /// when finished with it.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-linear
    pub fn createLinear(x0: f64, y0: f64, x1: f64, y1: f64) !Self {
        var c_ptr = c.cairo_pattern_create_linear(x0, y0, x1, y1);
        // cairo_pattern_create_linear always returns a valid pointer, but if an
        // error occurred the pattern status will be set to an error.
        _ = try Pattern.status(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    // TODO: add documentation and more tests
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-mesh
    pub fn createMesh() !Self {
        var c_ptr = c.cairo_pattern_create_mesh();
        _ = try Pattern.status(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// Create a new radial gradient between the two circles defined by (cx0,
    /// cy0, radius0) and (cx1, cy1, radius1). The caller owns the returned
    /// object and should call destroy() when finished with it.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-radial
    pub fn createRadial(cx0: f64, cy0: f64, radius0: f64, cx1: f64, cy1: f64, radius1: f64) !Self {
        var c_ptr = c.cairo_pattern_create_radial(cx0, cy0, radius0, cx1, cy1, radius1);
        // cairo_pattern_create_radial always returns a valid pointer, but if an
        // error occurred the pattern status will be set to an error.
        _ = try Pattern.status(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// Create a new pattern corresponding to an opaque color. The caller owns
    /// the returned object and should call destroy() when finished with it.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-rgb
    pub fn createRgb(red: f64, green: f64, blue: f64) !Self {
        var c_ptr = c.cairo_pattern_create_rgb(red, green, blue);
        // cairo_pattern_create_rgb always returns a valid pointer, but if an
        // error occurred the pattern status will be set to an error.
        _ = try Pattern.status(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// Create a new pattern corresponding to a translucent color. The caller
    /// owns the returned object and should call destroy() when finished with it.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-rgba
    pub fn createRgba(red: f64, green: f64, blue: f64, alpha: f64) !Self {
        var c_ptr = c.cairo_pattern_create_rgba(red, green, blue, alpha);
        // cairo_pattern_create_rgba always returns a valid pointer, but if an
        // error occurred the pattern status will be set to an error.
        _ = try Pattern.status(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-curve-to
    pub fn curveTo(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// Decrease the reference count on the C cairo_pattern_t struct by one. If
    /// the result is zero, then pattern and all associated resources are freed.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_pattern_destroy(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-end-patch
    pub fn endPatch(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// Get the number of color stops specified in the given gradient pattern.
    /// Calling getColorStopCount with a pattern which is not a gradient pattern
    /// is an error.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-color-stop-count
    pub fn getColorStopCount(self: *Self) !usize {
        var count: usize = 0;
        var c_ptr = @ptrCast([*c]c_int, &count);
        const c_integer = c.cairo_pattern_get_color_stop_count(self.c_ptr, c_ptr);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => count,
            c.CAIRO_STATUS_INVALID_INDEX => Error.InvalidIndex,
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }

    /// Get the color and offset information at the given index for a gradient pattern.
    /// Calling getColorStopRgba with a pattern which is not a gradient pattern
    /// is an error.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-color-stop-rgba
    pub fn getColorStopRgba(self: *Self, index: usize, offset: *f64, red: *f64, green: *f64, blue: *f64, alpha: *f64) !void {
        const c_integer = c.cairo_pattern_get_color_stop_rgba(self.c_ptr, @intCast(c_int, index), offset, red, green, blue, alpha);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {},
            c.CAIRO_STATUS_INVALID_INDEX => Error.InvalidIndex,
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-get-control-point
    pub fn getControlPoint(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-get-corner-color-rgba
    pub fn getCornerColorRgba(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-extend
    pub fn getExtend(self: *Self) Extend {
        return Extend.fromCairoEnum(c.cairo_pattern_get_extend(self.c_ptr));
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-filter
    pub fn getFilter(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-linear-points
    pub fn getLinearPoints(self: *Self, x0: *f64, y0: *f64, x1: *f64, y1: *f64) !void {
        const c_integer = c.cairo_pattern_get_linear_points(self.c_ptr, x0, y0, x1, y1);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {},
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }

    // TODO: is this working or not?
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-matrix
    pub fn getMatrix(self: *Self, matrix: *Matrix) void {
        c.cairo_pattern_get_matrix(self.c_ptr, matrix.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-get-patch-count
    pub fn getPatchCount(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-get-path
    pub fn getPath(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-radial-circles
    pub fn getRadialCircles(self: *Self, x0: *f64, y0: *f64, r0: *f64, x1: *f64, y1: *f64, r1: *f64) !void {
        const c_integer = c.cairo_pattern_get_radial_circles(self.c_ptr, x0, y0, r0, x1, y1, r1);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {},
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }

    /// Get the pattern's current reference count.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-reference-count
    pub fn getReferenceCount(self: *Self) c_uint {
        return c.cairo_pattern_get_reference_count(self.c_ptr);
    }

    /// Get the solid color for a solid color pattern.
    /// Calling getRgba with a pattern which is not a solid color pattern is an
    /// error.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-rgba
    pub fn getRgba(self: *Self, red: *f64, green: *f64, blue: *f64, alpha: *f64) !void {
        const c_integer = c.cairo_pattern_get_rgba(self.c_ptr, red, green, blue, alpha);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {},
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }

    /// Get the surface of a surface pattern. The reference returned in surface
    /// is owned by the pattern; the caller should call
    /// cairo_surface_reference() if the surface is to be retained.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-surface
    pub fn getSurface(self: *Self, surface: *Surface) !void {
        const c_ptr = @ptrCast([*c]?*c.struct__cairo_surface, &surface.c_ptr);
        const c_integer = c.cairo_pattern_get_surface(self.c_ptr, c_ptr);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {},
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }

    /// Get the pattern's type.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-type
    pub fn getType(self: *Self) PatternType {
        return PatternType.fromCairoEnum(c.cairo_pattern_get_type(self.c_ptr));
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-user-data
    pub fn getUserData(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-line-to
    pub fn lineTo(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-move-to
    pub fn moveTo(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    // TODO: should we return the original C pointer? Wrap it? Cast it? Should
    // we call Pattern.status?
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-reference
    pub fn reference(self: *Self) *c.struct__cairo_pattern {
        const c_ptr = c.cairo_pattern_reference(self.c_ptr);
        return c_ptr.?; // not sure if this should be optional or not
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-set-control-point
    pub fn setControlPoint(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-set-corner-color-rgb
    pub fn setCornerColorRgb(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-set-corner-color-rgba
    pub fn setCornerColorRgba(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-extend
    pub fn setExtend(self: *Self, extend: Extend) void {
        c.cairo_pattern_set_extend(self.c_ptr, extend.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-filter
    pub fn setFilter(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    // TODO: is this working or not?
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-matrix
    pub fn setMatrix(self: *Self, matrix: *Matrix) void {
        c.cairo_pattern_set_matrix(self.c_ptr, matrix.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-user-data
    pub fn setUserData(_: *Self) !void {
        @panic("TODO: to be implemented");
    }

    /// Check whether an error has previously occurred for this pattern.
    /// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-status
    pub fn status(c_ptr: ?*c.struct__cairo_pattern) !void {
        const c_integer = c.cairo_pattern_status(c_ptr);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {}, // nothing to do if successful
            c.CAIRO_STATUS_NO_MEMORY => Error.NoMemory,
            c.CAIRO_STATUS_INVALID_MATRIX => Error.InvalidMatrix,
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            c.CAIRO_STATUS_INVALID_MESH_CONSTRUCTION => Error.InvalidMeshConstruction,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }
};

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;

test "Pattern.status() returns no error" {
    var pattern = try Pattern.createRgb(1, 0, 0);
    defer pattern.destroy();

    var errored = false;
    _ = Pattern.status(pattern.c_ptr) catch {
        errored = true;
    };
    try expectEqual(false, errored);
}

test "reference() and destroy() modify the reference count as expected" {
    var pattern = try Pattern.createRgb(1, 0, 0);

    try expectEqual(@as(c_uint, 1), pattern.getReferenceCount());
    _ = pattern.reference();
    try expectEqual(@as(c_uint, 2), pattern.getReferenceCount());
    pattern.destroy();
    try expectEqual(@as(c_uint, 1), pattern.getReferenceCount());
    pattern.destroy();
    try expectEqual(@as(c_uint, 0), pattern.getReferenceCount());
}

test "addColorStopRgb() returns the expected error when the pattern is not a gradient pattern" {
    var pattern = try Pattern.createRgb(1, 0, 0);
    defer pattern.destroy();

    try expectError(error.PatternTypeMismatch, pattern.addColorStopRgb(0, 1, 0, 0));
}

test "addColorStopRgba() returns the expected error when the pattern is not a gradient pattern" {
    var pattern = try Pattern.createRgb(1, 0, 0);
    defer pattern.destroy();

    try expectError(error.PatternTypeMismatch, pattern.addColorStopRgba(0, 1, 0, 0, 1));
}

test "getColorStopCount() returns the expected color stops of a linear gradient" {
    var pattern = try Pattern.createLinear(0.0, 0.0, 0.0, 256.0);
    defer pattern.destroy();

    const n0 = try pattern.getColorStopCount();
    try expectEqual(@as(usize, 0), n0);

    const offset: f64 = 0.0;
    try pattern.addColorStopRgb(offset, 1, 0, 0);
    const n1 = try pattern.getColorStopCount();
    try expectEqual(@as(usize, 1), n1);

    try pattern.addColorStopRgb(offset, 0, 1, 0);
    const n2 = try pattern.getColorStopCount();
    try expectEqual(@as(usize, 2), n2);
}

test "getColorStopCount() returns the expected color stops of a radial gradient" {
    var pattern = try Pattern.createRadial(128, 128, 64, 128, 128, 128);
    defer pattern.destroy();

    const n0 = try pattern.getColorStopCount();
    try expectEqual(@as(usize, 0), n0);

    const offset: f64 = 0.0;
    try pattern.addColorStopRgb(offset, 1, 0, 0);
    const n1 = try pattern.getColorStopCount();
    try expectEqual(@as(usize, 1), n1);

    try pattern.addColorStopRgb(offset, 0, 1, 0);
    const n2 = try pattern.getColorStopCount();
    try expectEqual(@as(usize, 2), n2);
}

test "getColorStopRgba() sets offset, RGB, alpha with the expected values" {
    var pattern = try Pattern.createLinear(0.0, 0.0, 10.0, 10.0);
    defer pattern.destroy();

    var offset: f64 = undefined;
    var red: f64 = undefined;
    var green: f64 = undefined;
    var blue: f64 = undefined;
    var alpha: f64 = undefined;

    try pattern.addColorStopRgba(0.1, 1, 0.75, 0.5, 0.95); // offset,r,g,b,a

    var index: usize = 0;
    _ = try pattern.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha);
    try expectEqual(@as(f64, 0.1), offset);
    try expectEqual(@as(f64, 1), red);
    try expectEqual(@as(f64, 0.75), green);
    try expectEqual(@as(f64, 0.5), blue);
    try expectEqual(@as(f64, 0.95), alpha);

    try pattern.addColorStopRgba(0.2, 0.5, 0.6, 0.7, 1.0); // offset,r,g,b,a

    index = 1;
    _ = try pattern.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha);
    try expectEqual(@as(f64, 0.2), offset);
    try expectEqual(@as(f64, 0.5), red);
    try expectEqual(@as(f64, 0.6), green);
    try expectEqual(@as(f64, 0.7), blue);
    try expectEqual(@as(f64, 1.0), alpha);
}

test "getColorStopRgba() returns a PatternTypeMismatch error for non-gradial patterns" {
    var pattern_rgb = try Pattern.createRgb(1, 0, 0);
    defer pattern_rgb.destroy();

    var pattern_rgba = try Pattern.createRgba(1, 0, 0, 1);
    defer pattern_rgba.destroy();

    var surface = try Surface.image(20, 10);
    defer surface.destroy();
    var pattern_surface = try Pattern.createForSurface(&surface);
    defer pattern_surface.destroy();

    var pattern_mesh = try Pattern.createMesh();
    defer pattern_mesh.destroy();

    const index: usize = 0;
    var offset: f64 = undefined;
    var red: f64 = undefined;
    var green: f64 = undefined;
    var blue: f64 = undefined;
    var alpha: f64 = undefined;

    try expectError(error.PatternTypeMismatch, pattern_rgb.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha));
    try expectError(error.PatternTypeMismatch, pattern_rgba.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha));
    try expectError(error.PatternTypeMismatch, pattern_surface.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha));
    try expectError(error.PatternTypeMismatch, pattern_mesh.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha));
}

test "getColorStopRgba() returns a InvalidIndex error for gradial patterns with not enough color stops" {
    var pattern = try Pattern.createLinear(0, 0, 10, 10);
    defer pattern.destroy();

    var index: usize = 0;
    var offset: f64 = undefined;
    var red: f64 = undefined;
    var green: f64 = undefined;
    var blue: f64 = undefined;
    var alpha: f64 = undefined;

    try expectError(error.InvalidIndex, pattern.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha));

    // add a color stop => no errors if we pick the color whose index is 0
    try pattern.addColorStopRgb(0, 1, 0, 0);
    _ = try pattern.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha);

    // since we added a single color stop, we still have errors for indexes > 0
    index = 1;
    try expectError(error.InvalidIndex, pattern.getColorStopRgba(index, &offset, &red, &green, &blue, &alpha));
}

test "getExtend() returns Extend.pad for gradient patterns" {
    var pattern_rgb = try Pattern.createRgb(1, 0, 0);
    defer pattern_rgb.destroy();
    var pattern_rgba = try Pattern.createRgba(1, 0, 0, 1);
    defer pattern_rgba.destroy();
    var pattern_linear = try Pattern.createLinear(0.0, 0.0, 0.0, 256.0);
    defer pattern_linear.destroy();
    var pattern_radial = try Pattern.createRadial(128, 128, 64, 128, 128, 128);
    defer pattern_radial.destroy();

    try expectEqual(Extend.pad, pattern_rgb.getExtend());
    try expectEqual(Extend.pad, pattern_rgba.getExtend());
    try expectEqual(Extend.pad, pattern_linear.getExtend());
    try expectEqual(Extend.pad, pattern_radial.getExtend());
}

test "getExtend() returns Extend.none for surface patterns" {
    var surface = try Surface.image(20, 10);
    defer surface.destroy();
    var pattern = try Pattern.createForSurface(&surface);
    defer pattern.destroy();

    try expectEqual(Extend.none, pattern.getExtend());
}

test "getLinearPoints() returns a PatternTypeMismatch error for a non linear pattern" {
    var pattern = try Pattern.createRgb(1, 0, 0);
    defer pattern.destroy();

    var x0: f64 = undefined;
    var y0: f64 = undefined;
    var x1: f64 = undefined;
    var y1: f64 = undefined;
    try expectError(error.PatternTypeMismatch, pattern.getLinearPoints(&x0, &y0, &x1, &y1));
}

test "getLinearPoints() sets x0, y0, x1, y0 to the expected values" {
    var pattern = try Pattern.createLinear(1.0, 2.0, 10.0, 20.0);
    defer pattern.destroy();

    var x0: f64 = undefined;
    var y0: f64 = undefined;
    var x1: f64 = undefined;
    var y1: f64 = undefined;
    _ = try pattern.getLinearPoints(&x0, &y0, &x1, &y1);

    try expectEqual(@as(f64, 1), x0);
    try expectEqual(@as(f64, 2), y0);
    try expectEqual(@as(f64, 10), x1);
    try expectEqual(@as(f64, 20), y1);
}

test "getRadialCircles() returns a PatternTypeMismatch error for a non radial pattern" {
    var pattern = try Pattern.createRgb(1, 0, 0);
    defer pattern.destroy();

    var x0: f64 = undefined;
    var y0: f64 = undefined;
    var r0: f64 = undefined;
    var x1: f64 = undefined;
    var y1: f64 = undefined;
    var r1: f64 = undefined;
    try expectError(error.PatternTypeMismatch, pattern.getRadialCircles(&x0, &y0, &r0, &x1, &y1, &r1));
}

test "getRgba() returns a PatternTypeMismatch error for a pattern which is not a solid color pattern" {
    var surface = try Surface.image(20, 10);
    defer surface.destroy();
    var pattern_surface = try Pattern.createForSurface(&surface);
    defer pattern_surface.destroy();

    var pattern_linear = try Pattern.createLinear(0, 0, 10, 10);
    defer pattern_linear.destroy();

    var pattern_radial = try Pattern.createRadial(128, 128, 64, 128, 128, 128);
    defer pattern_radial.destroy();

    var pattern_mesh = try Pattern.createMesh();
    defer pattern_mesh.destroy();

    var red: f64 = undefined;
    var green: f64 = undefined;
    var blue: f64 = undefined;
    var alpha: f64 = undefined;

    try expectError(error.PatternTypeMismatch, pattern_surface.getRgba(&red, &green, &blue, &alpha));
    try expectError(error.PatternTypeMismatch, pattern_linear.getRgba(&red, &green, &blue, &alpha));
    try expectError(error.PatternTypeMismatch, pattern_radial.getRgba(&red, &green, &blue, &alpha));
    try expectError(error.PatternTypeMismatch, pattern_mesh.getRgba(&red, &green, &blue, &alpha));
}

test "getRgba() sets a RGB and alpha with the expected values" {
    var pattern_rgb = try Pattern.createRgb(1.0, 0.75, 0.5);
    defer pattern_rgb.destroy();

    var pattern_rgba = try Pattern.createRgba(0.1, 0.2, 0.3, 0.95);
    defer pattern_rgba.destroy();

    var red: f64 = undefined;
    var green: f64 = undefined;
    var blue: f64 = undefined;
    var alpha: f64 = undefined;

    _ = try pattern_rgb.getRgba(&red, &green, &blue, &alpha);
    try expectEqual(@as(f64, 1.0), red);
    try expectEqual(@as(f64, 0.75), green);
    try expectEqual(@as(f64, 0.5), blue);
    try expectEqual(@as(f64, 1.0), alpha);

    _ = try pattern_rgba.getRgba(&red, &green, &blue, &alpha);
    try expectEqual(@as(f64, 0.1), red);
    try expectEqual(@as(f64, 0.2), green);
    try expectEqual(@as(f64, 0.3), blue);
    try expectEqual(@as(f64, 0.95), alpha);
}

test "getSurface() returns a PatternTypeMismatch error for non-surface patterns" {
    var surface = try Surface.image(20, 10);
    defer surface.destroy();

    var pattern_rgb = try Pattern.createRgb(1, 0, 0);
    defer pattern_rgb.destroy();

    var pattern_rgba = try Pattern.createRgba(1, 0, 0, 1);
    defer pattern_rgba.destroy();

    var pattern_linear = try Pattern.createLinear(0.0, 0.0, 0.0, 256.0);
    defer pattern_linear.destroy();

    var pattern_radial = try Pattern.createRadial(128, 128, 64, 128, 128, 128);
    defer pattern_radial.destroy();

    var pattern_mesh = try Pattern.createMesh();
    defer pattern_mesh.destroy();

    try expectError(error.PatternTypeMismatch, pattern_rgb.getSurface(&surface));
    try expectError(error.PatternTypeMismatch, pattern_rgba.getSurface(&surface));
    try expectError(error.PatternTypeMismatch, pattern_linear.getSurface(&surface));
    try expectError(error.PatternTypeMismatch, pattern_radial.getSurface(&surface));
    try expectError(error.PatternTypeMismatch, pattern_mesh.getSurface(&surface));
}

test "getSurface() does not increase the reference count of the surface" {
    var surface = try Surface.image(20, 10);
    try expectEqual(@as(c_uint, 1), surface.getReferenceCount());

    var pattern = try Pattern.createForSurface(&surface); // refcount+1
    try expectEqual(@as(c_uint, 2), surface.getReferenceCount());

    _ = try pattern.getSurface(&surface); // does not increase refcount
    try expectEqual(@as(c_uint, 2), surface.getReferenceCount());

    // surface is a resource associated to pattern, so when pattern is destroyed
    // the refcount of surface decreases by 1
    pattern.destroy();
    try expectEqual(@as(c_uint, 1), surface.getReferenceCount());

    surface.destroy();
    try expectEqual(@as(c_uint, 0), surface.getReferenceCount());
}

test "getType() returns the expected pattern type" {
    var pattern_rgb = try Pattern.createRgb(1, 0, 0);
    defer pattern_rgb.destroy();

    var pattern_rgba = try Pattern.createRgba(1, 0, 0, 1);
    defer pattern_rgba.destroy();

    var surface = try Surface.image(20, 10);
    defer surface.destroy();
    var pattern_surface = try Pattern.createForSurface(&surface);
    defer pattern_surface.destroy();

    var pattern_linear = try Pattern.createLinear(0.0, 0.0, 0.0, 256.0);
    defer pattern_linear.destroy();

    var pattern_radial = try Pattern.createRadial(128, 128, 64, 128, 128, 128);
    defer pattern_radial.destroy();

    var pattern_mesh = try Pattern.createMesh();
    defer pattern_mesh.destroy();

    try expectEqual(PatternType.solid, pattern_rgb.getType());
    try expectEqual(PatternType.solid, pattern_rgba.getType());
    try expectEqual(PatternType.surface, pattern_surface.getType());
    try expectEqual(PatternType.linear, pattern_linear.getType());
    try expectEqual(PatternType.radial, pattern_radial.getType());
    try expectEqual(PatternType.mesh, pattern_mesh.getType());
    // TODO: how to build a cairo_pattern_t whose type is PatternType.raster_source?
    // try expectEqual(PatternType.raster_source, pattern_raster_source.getType());
}

test "setExtend() sets the expected Extend" {
    var pattern = try Pattern.createRgb(1, 0, 0);
    defer pattern.destroy();

    try expectEqual(Extend.pad, pattern.getExtend());

    pattern.setExtend(Extend.none);
    try expectEqual(Extend.none, pattern.getExtend());

    pattern.setExtend(Extend.repeat);
    try expectEqual(Extend.repeat, pattern.getExtend());

    pattern.setExtend(Extend.reflect);
    try expectEqual(Extend.reflect, pattern.getExtend());
}
