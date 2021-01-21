const std = @import("std");
const c = @import("c.zig");

// Import enums and assign them to a variable for clarity in this file, but also
// use `usingnamespace` for convenience when writing applications. This lets a
// user write either cairo.FillRule and cairo.enums.FillRule
const enums = @import("enums.zig");
usingnamespace enums;

usingnamespace @import("pattern.zig");

const text = @import("drawing/text.zig");
usingnamespace text;

usingnamespace @import("utilities/matrix.zig");
usingnamespace @import("surfaces/surfaces.zig");
const Error = @import("errors.zig").Error;

/// The cairo drawing context.
/// https://cairographics.org/manual/cairo-cairo-t.html
pub const Context = struct {
    cr: *c.struct__cairo,

    const Self = @This();
    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-create
    // TODO: keep original cairo API name?
    pub fn fromSurface(cs: *Surface) !Self {
        var cr: ?*c.cairo_t = c.cairo_create(cs.surface);
        if (cr == null) return Error.NullPointer;
        return Self{ .cr = cr.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_destroy(self.cr);
        // std.debug.print("cairo.Context {} destroyed\n", .{self});
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-rgb
    pub fn setSourceRgb(self: *Self, r: f64, g: f64, b: f64) void {
        c.cairo_set_source_rgb(self.cr, r, g, b);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-rgba
    pub fn setSourceRgba(self: *Self, r: f64, g: f64, b: f64, alpha: f64) void {
        c.cairo_set_source_rgba(self.cr, r, g, b, alpha);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-paint
    pub fn paint(self: *Self) void {
        c.cairo_paint(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-paint-with-alpha
    pub fn paintWithAlpha(self: *Self, alpha: f64) void {
        c.cairo_paint_with_alpha(self.cr, alpha);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-line-width
    pub fn setLineWidth(self: *Self, w: f64) void {
        c.cairo_set_line_width(self.cr, w);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-line-cap
    pub fn setLineCap(self: *Self, line_cap: enums.LineCap) void {
        c.cairo_set_line_cap(self.cr, line_cap.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-line-join
    pub fn setLineJoin(self: *Self, line_join: enums.LineJoin) void {
        c.cairo_set_line_join(self.cr, line_join.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-new-path
    pub fn newPath(self: *Self) void {
        c.cairo_new_path(self.cr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-new-sub-path
    pub fn newSubPath(self: *Self) void {
        c.cairo_new_sub_path(self.cr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-move-to
    pub fn moveTo(self: *Self, x: f64, y: f64) void {
        c.cairo_move_to(self.cr, x, y);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-line-to
    pub fn lineTo(self: *Self, x: f64, y: f64) void {
        c.cairo_line_to(self.cr, x, y);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rel-line-to
    pub fn relLineTo(self: *Self, dx: f64, dy: f64) void {
        c.cairo_rel_line_to(self.cr, dx, dy);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-curve-to
    pub fn curveTo(self: *Self, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) void {
        c.cairo_curve_to(self.cr, x1, y1, x2, y2, x3, y3);
    }

    /// https://cairographics.org/manual/cairo-Transformations.html#cairo-translate
    pub fn translate(self: *Self, tx: f64, ty: f64) void {
        c.cairo_translate(self.cr, tx, ty);
    }

    /// https://cairographics.org/manual/cairo-Transformations.html#cairo-scale
    pub fn scale(self: *Self, sx: f64, sy: f64) void {
        c.cairo_scale(self.cr, sx, sy);
    }

    /// https://cairographics.org/manual/cairo-Transformations.html#cairo-rotate
    pub fn rotate(self: *Self, radians: f64) void {
        c.cairo_rotate(self.cr, radians);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-stroke
    pub fn stroke(self: *Self) void {
        c.cairo_stroke(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-clip
    pub fn clip(self: *Self) void {
        c.cairo_clip(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill
    pub fn fill(self: *Self) void {
        c.cairo_fill(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill-preserve
    pub fn fillPreserve(self: *Self) void {
        c.cairo_fill_preserve(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-mask
    pub fn mask(self: *Self, pattern: *Pattern) void {
        c.cairo_mask(self.cr, pattern.pattern);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-pop-group-to-source
    pub fn popGroupToSource(self: *Self) void {
        c.cairo_pop_group_to_source(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-push-group
    pub fn pushGroup(self: *Self) void {
        c.cairo_push_group(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-fill-rule
    pub fn setFillRule(self: *Self, fill_rule: enums.FillRule) void {
        c.cairo_set_fill_rule(self.cr, fill_rule.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-arc
    pub fn arc(self: *Self, xc: f64, yc: f64, radius: f64, angle1: f64, angle2: f64) void {
        c.cairo_arc(self.cr, xc, yc, radius, angle1, angle2);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-arc-negative
    pub fn arcNegative(self: *Self, xc: f64, yc: f64, radius: f64, angle1: f64, angle2: f64) void {
        c.cairo_arc_negative(self.cr, xc, yc, radius, angle1, angle2);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rectangle
    pub fn rectangle(self: *Self, x: f64, y: f64, w: f64, h: f64) void {
        c.cairo_rectangle(self.cr, x, y, w, h);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-dash
    pub fn setDash(self: *Self, dashes: []f64, offset: f64) void {
        c.cairo_set_dash(self.cr, dashes.ptr, @intCast(c_int, dashes.len), offset);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-close-path
    pub fn closePath(self: *Self) void {
        c.cairo_close_path(self.cr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-restore
    pub fn restore(self: *Self) void {
        c.cairo_restore(self.cr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-save
    pub fn save(self: *Self) void {
        c.cairo_save(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-surface
    pub fn setSourceSurface(self: *Self, cs: *Surface, x: f64, y: f64) void {
        c.cairo_set_source_surface(self.cr, cs.surface, x, y);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source
    pub fn setSource(self: *Self, source: *Pattern) void {
        c.cairo_set_source(self.cr, source.pattern);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-select-font-face
    /// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2948
    pub fn selectFontFace(self: *Self, family: [*]const u8, slant: FontSlant, weight: FontWeight) void {
        const font_slant = @intToEnum(c.enum__cairo_font_slant, @enumToInt(slant));
        const font_weight = @intToEnum(c.enum__cairo_font_weight, @enumToInt(weight));
        c.cairo_select_font_face(self.cr, family, font_slant, font_weight);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-set-font-size
    pub fn setFontSize(self: *Self, size: f64) void {
        c.cairo_set_font_size(self.cr, size);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-text-extents
    pub fn textExtents(self: *Self, char: [*]const u8) TextExtents {
        c.cairo_text_extents(self.cr, char, &te);
        return TextExtents{
            .x_bearing = te.x_bearing,
            .x_advance = te.x_advance,
            .y_bearing = te.y_bearing,
            .y_advance = te.y_advance,
            .width = te.width,
            .height = te.height,
        };
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-show-text
    pub fn showText(self: *Self, char: [*]const u8) void {
        c.cairo_show_text(self.cr, char);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-text-path
    pub fn textPath(self: *Self, char: [*]const u8) void {
        c.cairo_text_path(self.cr, char);
    }
};

// https://github.com/freedesktop/cairo/blob/6a6ab2475906635fcc5ba0c73182fae73c4f7ee8/src/cairoint.h#L691
// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2925
pub const FontSlant = enum {
    Normal = c.CAIRO_FONT_SLANT_NORMAL,
    Italic = c.CAIRO_FONT_SLANT_ITALIC,
    Oblique = c.CAIRO_FONT_SLANT_OBLIQUE,
};

// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2938
pub const FontWeight = enum {
    Normal = c.CAIRO_FONT_WEIGHT_NORMAL,
    Bold = c.CAIRO_FONT_WEIGHT_BOLD,
};

var te: c.cairo_text_extents_t = undefined;

// https://cairographics.org/manual/cairo-cairo-scaled-font-t.html#cairo-text-extents-t
pub const TextExtents = struct {
    x_bearing: f64,
    y_bearing: f64,
    width: f64,
    height: f64,
    x_advance: f64,
    y_advance: f64,
};
