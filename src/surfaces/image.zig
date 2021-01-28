//! Cairo surface Image backend.
//! Image surfaces provide the ability to render to memory buffers either
//! allocated by cairo or by the calling code.
//! The supported image formats are those defined in cairo_format_t.
//! https://www.cairographics.org/manual/cairo-Image-Surfaces.html
const std = @import("std");
const c = @import("../c.zig");
const Error = @import("../utilities/error_handling.zig").Error;
const Format = @import("../enums.zig").Format;

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-create
pub fn create(format: Format, width: u16, height: u16) !*c.struct__cairo_surface {
    // cairo_image_surface_create always returns a valid pointer, but it will
    // return a pointer to a "nil" surface if an error such as out of memory
    // occurs. You can use cairo_surface_status() to check for this.
    return c.cairo_image_surface_create(format.toCairoEnum(), width, height).?;
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-create-for-data
pub fn createForData() void {
    @panic("TODO: to be implemented");
}

/// Get a pointer to the data of the image surface, for direct inspection or modification.
/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-data
pub fn getData(surface: *c.struct__cairo_surface) ![*c]u8 {
    const c_ptr = c.cairo_image_surface_get_data(surface);
    // The pointer returned by cairo_image_surface_get_data is NULL if surface
    // is not an image surface, or if cairo_surface_finish() has been called.
    if (c_ptr == null) return Error.SurfaceTypeMismatch;
    return c_ptr;
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-format
pub fn getFormat(surface: *c.struct__cairo_surface) Format {
    return Format.fromCairoEnum(c.cairo_image_surface_get_format(surface));
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-height
pub fn getHeight(surface: *c.struct__cairo_surface) u16 {
    return @intCast(u16, c.cairo_image_surface_get_height(surface));
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-stride
pub fn getStride(surface: *c.struct__cairo_surface) u16 {
    return @intCast(u16, c.cairo_image_surface_get_stride(surface));
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-width
pub fn getWidth(surface: *c.struct__cairo_surface) u16 {
    return @intCast(u16, c.cairo_image_surface_get_width(surface));
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-format-stride-for-width
pub fn formatStrideForWidth() void {
    @panic("TODO: to be implemented");
}
