//! Creating paths and manipulating path data
const std = @import("std");
const log = std.log;
const c = @import("../c.zig");
// const Error = @import("../errors.zig").Error;

/// A path is represented as an array of cairo_path_data_t, which is a union of
/// headers and points.
const PathIterator = struct {
    i: usize,
    num_data: c_int,
    data: [*]c.union__cairo_path_data_t,

    const Self = @This();

    /// Get the next PathDataType from the array of cairo_path_data_t elements.
    pub fn next(self: *Self) ?PathDataType {
        if (self.i >= self.num_data) {
            return null;
        }
        // the value of step varies, since the length value of the header is the
        // number of array elements for the current portion including the header
        // (ie. length == 1 + # of points)
        // https://cairographics.org/manual/cairo-Paths.html#cairo-path-data-t
        defer self.i += @intCast(usize, self.data[self.i].header.length);
        return pathDataType(self.data[self.i].header.type);
    }
};

/// https://cairographics.org/manual/cairo-Paths.html#cairo-path-t
pub const Path = struct {
    c_ptr: *c.struct_cairo_path,

    const Self = @This();

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-path-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_path_destroy(self.c_ptr);
    }

    pub fn iterator(self: *Self) PathIterator {
        return PathIterator{
            .i = 0,
            .data = self.c_ptr.data,
            .num_data = self.c_ptr.num_data,
        };
    }
};

/// https://cairographics.org/manual/cairo-Paths.html#cairo-path-data-type-t
pub const PathDataType = enum {
    MoveTo = c.CAIRO_PATH_MOVE_TO,
    LineTo = c.CAIRO_PATH_LINE_TO,
    CurveTo = c.CAIRO_PATH_CURVE_TO,
    ClosePath = c.CAIRO_PATH_CLOSE_PATH,
};

/// Convert the C enum into a Zig enum.
pub fn pathDataType(c_enum: c.enum__cairo_path_data_type) PathDataType {
    return switch (@enumToInt(c_enum)) {
        c.CAIRO_PATH_MOVE_TO => PathDataType.MoveTo,
        c.CAIRO_PATH_LINE_TO => PathDataType.LineTo,
        c.CAIRO_PATH_CURVE_TO => PathDataType.CurveTo,
        c.CAIRO_PATH_CLOSE_PATH => PathDataType.ClosePath,
        else => unreachable, // we know that cairo_path_data_type_t has no other member
    };
}
/// A path is represented as an array of cairo_path_data_t, which is a union of headers and points.
// pub const PathData = struct {
//     c_ptr: [*]c.union__cairo_path_data_t,
// };
/// https://cairographics.org/manual/cairo-Paths.html#cairo-path-data-t
pub const CUnionPathData = c.union__cairo_path_data_t;
