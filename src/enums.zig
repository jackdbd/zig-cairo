//! Enums used in Cairo.
const c = @import("c.zig");

/// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-extend-t
pub const Extend = enum {
    None = c.CAIRO_EXTEND_NONE, // 0
    Repeat = c.CAIRO_EXTEND_REPEAT, // 1
    Reflect = c.CAIRO_EXTEND_REFLECT, // 2
    Pad = c.CAIRO_EXTEND_PAD, // 3

    pub fn toCairoEnum(self: Extend) c.enum__cairo_extend {
        const c_integer = @enumToInt(self);
        return @intToEnum(c.enum__cairo_extend, @intCast(u2, c_integer));
    }
};

/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill-rule-t
pub const FillRule = enum {
    Winding = c.CAIRO_FILL_RULE_WINDING,
    EvenOdd = c.CAIRO_FILL_RULE_EVEN_ODD,

    pub fn toCairoEnum(self: FillRule) c.enum__cairo_fill_rule {
        const c_integer = @enumToInt(self);
        return @intToEnum(c.enum__cairo_fill_rule, @intCast(u1, c_integer));
    }
};

/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-line-cap-t
pub const LineCap = enum {
    Butt = c.CAIRO_LINE_CAP_BUTT,
    Round = c.CAIRO_LINE_CAP_ROUND,
    Square = c.CAIRO_LINE_CAP_SQUARE,

    pub fn toCairoEnum(self: LineCap) c.enum__cairo_line_cap {
        const c_integer = @enumToInt(self);
        return @intToEnum(c.enum__cairo_line_cap, @intCast(u2, c_integer));
    }
};

/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-line-join-t
pub const LineJoin = enum {
    Miter = c.CAIRO_LINE_JOIN_MITER,
    Round = c.CAIRO_LINE_JOIN_ROUND,
    Bevel = c.CAIRO_LINE_JOIN_BEVEL,

    pub fn toCairoEnum(self: LineJoin) c.enum__cairo_line_join {
        const c_integer = @enumToInt(self);
        return @intToEnum(c.enum__cairo_line_join, @intCast(u2, c_integer));
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
