//! Cairo surface SVG backend.
//! The SVG surface is used to render cairo graphics to SVG files and is a
//! multi-page vector surface backend.
//! https://www.cairographics.org/manual/cairo-SVG-Surfaces.html
const c = @import("../c.zig");
const Error = @import("../errors.zig").Error;

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-create
pub fn create(comptime filename: [*]const u8, width_pt: f64, height_pt: f64) !*c.struct__cairo_surface {
    var surface = c.cairo_svg_surface_create(filename, width_pt, height_pt);
    if (surface == null) return Error.NullPointer;
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
    User = c.CAIRO_SVG_UNIT_USER,
    Em = c.CAIRO_SVG_UNIT_EM,
    Ex = c.CAIRO_SVG_UNIT_EX,
    Px = c.CAIRO_SVG_UNIT_PX,
    In = c.CAIRO_SVG_UNIT_IN,
    Cm = c.CAIRO_SVG_UNIT_CM,
    Mm = c.CAIRO_SVG_UNIT_MM,
    Pt = c.CAIRO_SVG_UNIT_PT,
    Pc = c.CAIRO_SVG_UNIT_PC,
    Percent = c.CAIRO_SVG_UNIT_PERCENT,
};
