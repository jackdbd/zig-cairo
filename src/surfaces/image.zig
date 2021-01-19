//! Cairo surface Image backend.
//! Image surfaces provide the ability to render to memory buffers either
//! allocated by cairo or by the calling code.
//! The supported image formats are those defined in cairo_format_t.
//! https://www.cairographics.org/manual/cairo-Image-Surfaces.html
const c = @import("../c.zig");
const Status = @import("../status.zig").Status;

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-create
pub fn create(comptime format: Format, comptime width: u16, comptime height: u16) !*c.struct__cairo_surface {
    const c_enum = @intToEnum(c.enum__cairo_format, @enumToInt(format));
    var surface = c.cairo_image_surface_create(c_enum, width, height);
    if (surface == null) return Status.NullPointer;
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

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-format-t
pub const Format = enum {
    Invalid,
    Argb32,
    Rgb24,
    A8,
    A1,
    Rgb16_565,
    Rgb30,
};
