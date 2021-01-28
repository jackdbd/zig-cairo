//! Cairo surface Image backend.
//! Image surfaces provide the ability to render to memory buffers either
//! allocated by cairo or by the calling code.
//! The supported image formats are those defined in cairo_format_t.
//! https://www.cairographics.org/manual/cairo-Image-Surfaces.html
const std = @import("std");
const c = @import("../c.zig");
const Error = @import("../errors.zig").Error;
const Format = @import("../enums.zig").Format;

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-create
pub fn create(format: Format, width: u16, height: u16) !*c.struct__cairo_surface {
    const c_enum = @intToEnum(c.enum__cairo_format, @enumToInt(format));
    var surface = c.cairo_image_surface_create(c_enum, width, height);
    if (surface == null) return Error.NullPointer;
    return surface.?;
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-format
pub fn getFormat(surface: *c.struct__cairo_surface) Format {
    const c_enum = c.cairo_image_surface_get_format(surface);
    const c_integer = @enumToInt(c_enum);
    return @intToEnum(Format, @intCast(u3, c_integer));
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-width
pub fn getWidth(surface: *c.struct__cairo_surface) u16 {
    return @intCast(u16, c.cairo_image_surface_get_width(surface));
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-height
pub fn getHeight(surface: *c.struct__cairo_surface) u16 {
    return @intCast(u16, c.cairo_image_surface_get_height(surface));
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-data
pub fn getData(surface: *c.struct__cairo_surface) ![*c]u8 {
    const char = c.cairo_image_surface_get_data(surface);
    if (char == null) return Error.NullPointer;
    // use @ptrCast?
    return char;
}

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-stride
pub fn getStride(surface: *c.struct__cairo_surface) u16 {
    return @intCast(u16, c.cairo_image_surface_get_stride(surface));
}
