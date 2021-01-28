//! Cairo surface PDF backend.
//! The PDF surface is used to render cairo graphics to Adobe PDF files and is a
//! multi-page vector surface backend.
//! https://www.cairographics.org/manual/cairo-PDF-Surfaces.html
const c = @import("../c.zig");
const Error = @import("../utilities/error_handling.zig").Error;
const enums = @import("../enums.zig");
const PdfMetadata = enums.PdfMetadata;

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-add-outline
pub fn addOutline() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-create-for-stream
pub fn createForStream() void {
    @panic("TODO: to be implemented");
}

/// Create a PDF surface of the specified size in points to be written to filename.
/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-create
pub fn create(comptime filename: []const u8, width_pt: f64, height_pt: f64) !*c.struct__cairo_surface {
    // cairo_pdf_surface_create always returns a valid pointer, but it will
    // return a pointer to a "nil" surface if an error such as out of memory
    // occurs. You can use cairo_surface_status() to check for this.
    return c.cairo_pdf_surface_create(filename.ptr, width_pt, height_pt).?;
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-get-versions
pub fn getVersions() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-restrict-to-version
pub fn restrictToVersion() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-set-metadata
pub fn setMetadata(surface: *c.struct__cairo_surface, metadata: PdfMetadata, char: []const u8) void {
    c.cairo_pdf_surface_set_metadata(surface, metadata.toCairoEnum(), char.ptr);
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-set-page-label
pub fn setPageLabel(surface: *c.struct__cairo_surface, char: []const u8) void {
    c.cairo_pdf_surface_set_page_label(surface, char.ptr);
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-set-size
pub fn setSize(surface: *c.struct__cairo_surface, width_pt: f64, height_pt: f64) void {
    c.cairo_pdf_surface_set_size(surface, width_pt, height_pt);
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-set-thumbnail-size
pub fn setThumbnailSize() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-version-to-string
pub fn versionToString() void {
    @panic("TODO: to be implemented");
}
