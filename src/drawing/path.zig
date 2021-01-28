//! Creating paths and manipulating path data.
const std = @import("std");
const c = @import("../c.zig");
const PathDataType = @import("../enums.zig").PathDataType;
const Error = @import("../utilities/error_handling.zig").Error;

/// Convenience struct to iterate over the data elements in a Cairo path.
const PathIterator = struct {
    /// Index for the data elements. The increment varies according the header
    /// of the PathDataType (see the next() method).
    i: usize,
    /// Number of elements in the data array. An empty path has num_data = 0.
    num_data: c_int,
    /// Elements in the path. A path is represented as an array of
    /// cairo_path_data_t, which is a C union of headers and points.
    /// It's an optional pointer, since an empty path has no data elements.
    data: ?[*]c.union__cairo_path_data_t,

    const Self = @This();

    /// Get the next PathDataType from the array of cairo_path_data_t elements.
    pub fn next(self: *Self) ?PathDataType {
        if (self.i >= self.num_data) {
            return null;
        }
        // The value of step varies, since the length value of the header is the
        // number of array elements for the current portion including the header
        // (ie. length == 1 + # of points)
        // https://cairographics.org/manual/cairo-Paths.html#cairo-path-data-t
        defer self.i += @intCast(usize, self.data.?[self.i].header.length); // step
        return PathDataType.fromCairoEnum(self.data.?[self.i].header.type);
    }
};

// TODO: add method to construct a Path manually (useful in tests and maybe elsewhere).

/// Wrapper for the Cairo cairo_path_t C struct.
/// Note that most of the functions defined in the cairo-Paths section of the
/// Cairo C API are defined in zig-cairo Context, since they require a cairo_t
/// as their first parameter.
pub const Path = struct {
    /// The original cairo_path_t C struct.
    /// https://cairographics.org/manual/cairo-Paths.html#cairo-path-t
    c_ptr: *c.struct_cairo_path,

    const Self = @This();

    /// Immediately release all memory associated with the wrapped cairo_path_t.
    /// https://cairographics.org/manual/cairo-Paths.html#cairo-path-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_path_destroy(self.c_ptr);
    }

    /// Convenience method to avoid having to manually iterate over
    /// cairo_path_data_t, which is an optional C pointer of unknown length.
    pub fn iterator(self: *Self) PathIterator {
        // TODO: it would be nicer to use a Zig slice. How can I build it from a
        // C pointer?
        return PathIterator{
            .i = 0,
            .data = self.c_ptr.data, // it's @ptrCast(?[*]c.union__cairo_path_data_t, self.c_ptr.data);
            .num_data = self.c_ptr.num_data,
        };
    }

    // TODO: read Cairo source code to understand which status to check here.
    /// Check whether an error has previously occurred for this path.
    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-status
    pub fn status(c_ptr: *c.struct_cairo_path) !void {
        const c_integer = @enumToInt(c_ptr.status);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {}, // nothing to do if successful
            c.CAIRO_STATUS_NO_MEMORY => Error.NoMemory,
            c.CAIRO_STATUS_INVALID_PATH_DATA => Error.InvalidPathData,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }
};
