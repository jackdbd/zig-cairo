//! Cairo surface SVG backend.
//! The SVG surface is used to render cairo graphics to SVG files and is a
//! multi-page vector surface backend.
//! https://www.cairographics.org/manual/cairo-SVG-Surfaces.html
const c = @import("../c.zig");
const Error = @import("../utilities/error_handling.zig").Error;
const Unit = @import("../enums.zig").Unit;

/// Create a SVG surface of the specified size in points to be written to filename.
/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-create
pub fn create(comptime filename: []const u8, width_pt: f64, height_pt: f64) !*c.struct__cairo_surface {
    // cairo_svg_surface_create always returns a valid pointer, but it will
    // return a pointer to a "nil" surface if an error such as out of memory
    // occurs. You can use cairo_surface_status() to check for this.
    return c.cairo_svg_surface_create(filename.ptr, width_pt, height_pt).?;
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-create-for-stream
pub fn createForStream() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-get-document-unit
pub fn getDocumentUnit(surface: *c.struct__cairo_surface) Unit {
    return Unit.fromCairoEnum(c.cairo_svg_surface_get_document_unit(surface));
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-get-versions
pub fn getVersions() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-restrict-to-version
pub fn restrictToVersion() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-set-document-unit
pub fn setDocumentUnit(surface: *c.struct__cairo_surface, unit: Unit) void {
    // TODO: check that the surface passed is a SVG surface
    const u = @intToEnum(c.enum__cairo_svg_unit, @enumToInt(unit));
    c.cairo_svg_surface_set_document_unit(surface, u);
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-version-to-string
pub fn versionToString() void {
    @panic("TODO: to be implemented");
}
