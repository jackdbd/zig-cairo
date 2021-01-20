//! Cairo surface PDF backend.
//! The PDF surface is used to render cairo graphics to Adobe PDF files and is a
//! multi-page vector surface backend.
//! https://www.cairographics.org/manual/cairo-PDF-Surfaces.html
const c = @import("../c.zig");
const Error = @import("../errors.zig").Error;

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-create
pub fn create(comptime filename: [*]const u8, comptime width_pt: f64, comptime height_pt: f64) !*c.struct__cairo_surface {
    var surface = c.cairo_pdf_surface_create(filename, width_pt, height_pt);
    if (surface == null) return Error.NullPointer;
    return surface.?;
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-set-size
pub fn setSize(surface: *c.struct__cairo_surface, width_pt: f64, height_pt: f64) void {
    c.cairo_pdf_surface_set_size(surface, width_pt, height_pt);
}
