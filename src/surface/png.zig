//! Cairo surface PNG backend.
//! The PNG functions allow reading PNG images into image surfaces, and writing
//! any surface to a PNG file.
//! https://www.cairographics.org/manual/cairo-PNG-Support.html
const c = @import("../c.zig");
const Status = @import("../status.zig").Status;

/// https://www.cairographics.org/manual/cairo-PNG-Support.html#cairo-image-surface-create-from-png
pub fn createFromPng(filename: [*]const u8) !*c.struct__cairo_surface {
    var surface = c.cairo_image_surface_create_from_png(filename);
    // TODO: error handling:
    // CAIRO_STATUS_NO_MEMORY
    // CAIRO_STATUS_FILE_NOT_FOUND
    // CAIRO_STATUS_READ_ERROR
    // CAIRO_STATUS_PNG_ERROR
    if (surface == null) return Status.NullPointer;
    return surface.?;
}
