//! Cairo surface SVG backend.
//! The SVG surface is used to render cairo graphics to SVG files and is a
//! multi-page vector surface backend.
//! https://www.cairographics.org/manual/cairo-SVG-Surfaces.html
const c = @import("../c.zig");
const Status = @import("../status.zig").Status;

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-create
pub fn create(comptime filename: [*]const u8, comptime width_pt: f64, comptime height_pt: f64) !*c.struct__cairo_surface {
    comptime {
        if (width_pt < 0) {
            @compileError("`width_pt` must be positive");
        }
        if (height_pt < 0) {
            @compileError("`height_pt` must be positive");
        }
        // TODO: filename must be writable
    }
    var surface = c.cairo_svg_surface_create(filename, width_pt, height_pt);
    if (surface == null) return Status.NullPointer;
    return surface.?;
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-get-document-unit
pub fn getDocumentUnit(surface: *c.struct__cairo_surface) Unit {
    // TODO: check that the surface passed is a SVG surface
    const c_enum = c.cairo_svg_surface_get_document_unit(surface);
    const c_integer = @enumToInt(c_enum);
    return @intToEnum(Unit, @intCast(u4, c_integer));
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-set-document-unit
pub fn setDocumentUnit(surface: *c.struct__cairo_surface, unit: Unit) void {
    // TODO: check that the surface passed is a SVG surface
    const u = @intToEnum(c.enum__cairo_svg_unit, @enumToInt(unit));
    c.cairo_svg_surface_set_document_unit(surface, u);
}

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-unit-t
pub const Unit = enum {
    User,
    Em,
    Ex,
    Px,
    In,
    Cm,
    Mm,
    Pt,
    Pc,
    Percent,
};
