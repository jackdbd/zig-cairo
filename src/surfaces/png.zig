//! Cairo surface PNG backend.
//! The PNG functions allow reading PNG images into image surfaces, and writing
//! any surface to a PNG file.
//! https://www.cairographics.org/manual/cairo-PNG-Support.html
const c = @import("../c.zig");
const Error = @import("../utilities/error_handling.zig").Error;

/// https://www.cairographics.org/manual/cairo-PNG-Support.html#cairo-image-surface-create-from-png
pub fn createFromPng(filename: []const u8) !*c.struct__cairo_surface {
    // cairo_image_surface_create_from_png always returns a valid pointer, but
    // it will return a pointer to a "nil" surface if any error occured. You can
    // use cairo_surface_status() to check for this.
    return c.cairo_image_surface_create_from_png(filename.ptr).?;
}

/// https://www.cairographics.org/manual/cairo-PNG-Support.html#cairo-image-surface-create-from-png-stream
pub fn createFromPngStream() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-PNG-Support.html#cairo-surface-write-to-png
pub fn writeToPng() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-PNG-Support.html#cairo-surface-write-to-png-stream
pub fn writeToPngStream() void {
    @panic("TODO: to be implemented");
}
