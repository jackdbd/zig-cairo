//! Enums used in Cairo.
const std = @import("std");
const c = @import("c.zig");

/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-antialias-t
pub const Antialias = enum {
    default,
    none,
    gray,
    subpixel,
    fast,
    good,
    best,

    /// Convert from the C enum returned by Cairo into a Zig enum (for convenience).
    pub fn fromCairoEnum(c_enum: c.enum__cairo_antialias) Antialias {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_ANTIALIAS_DEFAULT => Antialias.default,
            c.CAIRO_ANTIALIAS_NONE => Antialias.none,
            c.CAIRO_ANTIALIAS_GRAY => Antialias.gray,
            c.CAIRO_ANTIALIAS_SUBPIXEL => Antialias.subpixel,
            c.CAIRO_ANTIALIAS_FAST => Antialias.fast,
            c.CAIRO_ANTIALIAS_GOOD => Antialias.good,
            c.CAIRO_ANTIALIAS_BEST => Antialias.best,
            else => std.debug.panic("cairo_antialias_t member {} not handled.", .{c_integer}),
        };
    }

    /// Convert the Zig enum into the C enum that Cairo expects.
    pub fn toCairoEnum(self: Antialias) c.enum__cairo_antialias {
        return switch (self) {
            .default => @intToEnum(c.enum__cairo_antialias, c.CAIRO_ANTIALIAS_DEFAULT),
            .none => @intToEnum(c.enum__cairo_antialias, c.CAIRO_ANTIALIAS_NONE),
            .gray => @intToEnum(c.enum__cairo_antialias, c.CAIRO_ANTIALIAS_GRAY),
            .subpixel => @intToEnum(c.enum__cairo_antialias, c.CAIRO_ANTIALIAS_SUBPIXEL),
            .fast => @intToEnum(c.enum__cairo_antialias, c.CAIRO_ANTIALIAS_FAST),
            .good => @intToEnum(c.enum__cairo_antialias, c.CAIRO_ANTIALIAS_GOOD),
            .best => @intToEnum(c.enum__cairo_antialias, c.CAIRO_ANTIALIAS_BEST),
        };
    }
};

/// https://cairographics.org/manual/cairo-cairo-surface-t.html#cairo-content-t
/// https://gitlab.freedesktop.org/cairo/cairo/-/blob/master/src/cairo.h#L379
pub const Content = enum {
    color, // in Cairo is 0x1000 i.e. 4096
    alpha, // in Cairo is0x2000 i.e. 8192
    color_alpha, // in Cairo is 0x3000 i.e. 12288

    pub fn fromCairoEnum(c_enum: c.enum__cairo_content) Content {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_CONTENT_COLOR => Content.color,
            c.CAIRO_CONTENT_ALPHA => Content.alpha,
            c.CAIRO_CONTENT_COLOR_ALPHA => Content.color_alpha,
            else => std.debug.panic("cairo_content_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: Content) c.enum__cairo_content {
        return switch (self) {
            .color => @intToEnum(c.enum__cairo_content, c.CAIRO_CONTENT_COLOR),
            .alpha => @intToEnum(c.enum__cairo_content, c.CAIRO_CONTENT_ALPHA),
            .color_alpha => @intToEnum(c.enum__cairo_content, c.CAIRO_CONTENT_COLOR_ALPHA),
        };
    }
};

/// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-type-t
pub const DeviceType = enum {
    drm = c.CAIRO_DEVICE_TYPE_DRM,
    gl = c.CAIRO_DEVICE_TYPE_GL,
    script = c.CAIRO_DEVICE_TYPE_SCRIPT,
    xcb = c.CAIRO_DEVICE_TYPE_XCB,
    xlib = c.CAIRO_DEVICE_TYPE_XLIB,
    xml = c.CAIRO_DEVICE_TYPE_XML,
    cogl = c.CAIRO_DEVICE_TYPE_COGL,
    win32 = c.CAIRO_DEVICE_TYPE_WIN32,
    // invalid = c.CAIRO_DEVICE_TYPE_INVALID, // -1

    pub fn fromCairoEnum(c_enum: c.enum__cairo_device_type) DeviceType {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_DEVICE_TYPE_DRM => DeviceType.drm,
            c.CAIRO_DEVICE_TYPE_GL => DeviceType.gl,
            c.CAIRO_DEVICE_TYPE_SCRIPT => DeviceType.script,
            c.CAIRO_DEVICE_TYPE_XCB => DeviceType.xcb,
            c.CAIRO_DEVICE_TYPE_XLIB => DeviceType.xlib,
            c.CAIRO_DEVICE_TYPE_XML => DeviceType.xml,
            c.CAIRO_DEVICE_TYPE_COGL => DeviceType.cogl,
            c.CAIRO_DEVICE_TYPE_WIN32 => DeviceType.win32,
            // c.CAIRO_DEVICE_TYPE_INVALID => DeviceType.invalid,
            else => std.debug.panic("cairo_device_type_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: DeviceType) c.enum__cairo_device_type {
        return switch (self) {
            .drm => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_DRM),
            .gl => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_GL),
            .script => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_SCRIPT),
            .xcb => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_XCB),
            .xlib => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_XLIB),
            .xml => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_XML),
            .cogl => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_WIN32),
            .win32 => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_COGL),
            // .invalid => @intToEnum(c.enum__cairo_device_type, c.CAIRO_DEVICE_TYPE_INVALID),
        };
    }
};

/// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-extend-t
pub const Extend = enum {
    none = c.CAIRO_EXTEND_NONE,
    repeat = c.CAIRO_EXTEND_REPEAT,
    reflect = c.CAIRO_EXTEND_REFLECT,
    pad = c.CAIRO_EXTEND_PAD,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_extend) Extend {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_EXTEND_NONE => Extend.none,
            c.CAIRO_EXTEND_REPEAT => Extend.repeat,
            c.CAIRO_EXTEND_REFLECT => Extend.reflect,
            c.CAIRO_EXTEND_PAD => Extend.pad,
            else => std.debug.panic("cairo_extend_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: Extend) c.enum__cairo_extend {
        const c_integer = @enumToInt(self);
        return switch (self) {
            .none => @intToEnum(c.enum__cairo_extend, c.CAIRO_EXTEND_NONE),
            .repeat => @intToEnum(c.enum__cairo_extend, c.CAIRO_EXTEND_REPEAT),
            .reflect => @intToEnum(c.enum__cairo_extend, c.CAIRO_EXTEND_REFLECT),
            .pad => @intToEnum(c.enum__cairo_extend, c.CAIRO_EXTEND_PAD),
        };
    }
};

/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill-rule-t
pub const FillRule = enum {
    winding = c.CAIRO_FILL_RULE_WINDING,
    even_odd = c.CAIRO_FILL_RULE_EVEN_ODD,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_fill_rule) FillRule {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_FILL_RULE_WINDING => FillRule.winding,
            c.CAIRO_FILL_RULE_EVEN_ODD => FillRule.even_odd,
            else => std.debug.panic("cairo_fill_rule_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: FillRule) c.enum__cairo_fill_rule {
        return switch (self) {
            .winding => @intToEnum(c.enum__cairo_fill_rule, c.CAIRO_FILL_RULE_WINDING),
            .even_odd => @intToEnum(c.enum__cairo_fill_rule, c.CAIRO_FILL_RULE_EVEN_ODD),
        };
    }
};

/// https://github.com/freedesktop/cairo/blob/6a6ab2475906635fcc5ba0c73182fae73c4f7ee8/src/cairoint.h#L691
/// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2925
pub const FontSlant = enum {
    normal = c.CAIRO_FONT_SLANT_NORMAL,
    italic = c.CAIRO_FONT_SLANT_ITALIC,
    oblique = c.CAIRO_FONT_SLANT_OBLIQUE,
};

/// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2938
pub const FontWeight = enum {
    normal = c.CAIRO_FONT_WEIGHT_NORMAL,
    bold = c.CAIRO_FONT_WEIGHT_BOLD,
};

/// https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-format-t
/// https://github.com/freedesktop/cairo/blob/6a6ab2475906635fcc5ba0c73182fae73c4f7ee8/src/cairo.h#L418
pub const Format = enum {
    // invalid = c.CAIRO_FORMAT_INVALID, // -1
    argb32 = c.CAIRO_FORMAT_ARGB32, // 0
    rgb24 = c.CAIRO_FORMAT_RGB24, // 1
    a8 = c.CAIRO_FORMAT_A8, // 2
    a1 = c.CAIRO_FORMAT_A1, // 3
    rgb16_565 = c.CAIRO_FORMAT_RGB16_565, // 4
    rgb30 = c.CAIRO_FORMAT_RGB30, // 5
    // rgb96f = c.CAIRO_FORMAT_RGB96F, // 6
    // rgba128f = c.CAIRO_FORMAT_RGBA128F, // 7

    pub fn fromCairoEnum(c_enum: c.enum__cairo_format) Format {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_FORMAT_ARGB32 => Format.argb32,
            c.CAIRO_FORMAT_RGB24 => Format.rgb24,
            c.CAIRO_FORMAT_A8 => Format.a8,
            c.CAIRO_FORMAT_A1 => Format.a1,
            c.CAIRO_FORMAT_RGB16_565 => Format.rgb16_565,
            c.CAIRO_FORMAT_RGB30 => Format.rgb30,
            else => std.debug.panic("cairo_format_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: Format) c.enum__cairo_format {
        return switch (self) {
            // .invalid => @intToEnum(c.enum__cairo_format, c.CAIRO_FORMAT_INVALID),
            .argb32 => @intToEnum(c.enum__cairo_format, c.CAIRO_FORMAT_ARGB32),
            .rgb24 => @intToEnum(c.enum__cairo_format, c.CAIRO_FORMAT_RGB24),
            .a8 => @intToEnum(c.enum__cairo_format, c.CAIRO_FORMAT_A8),
            .a1 => @intToEnum(c.enum__cairo_format, c.CAIRO_FORMAT_A1),
            .rgb16_565 => @intToEnum(c.enum__cairo_format, c.CAIRO_FORMAT_RGB16_565),
            .rgb30 => @intToEnum(c.enum__cairo_format, c.CAIRO_FORMAT_RGB30),
        };
    }
};

/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-line-cap-t
pub const LineCap = enum {
    butt = c.CAIRO_LINE_CAP_BUTT,
    round = c.CAIRO_LINE_CAP_ROUND,
    square = c.CAIRO_LINE_CAP_SQUARE,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_line_cap) LineCap {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_LINE_CAP_BUTT => LineCap.butt,
            c.CAIRO_LINE_CAP_ROUND => LineCap.round,
            c.CAIRO_LINE_CAP_SQUARE => LineCap.square,
            else => std.debug.panic("cairo_line_cap_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: LineCap) c.enum__cairo_line_cap {
        return switch (self) {
            .butt => @intToEnum(c.enum__cairo_line_cap, c.CAIRO_LINE_CAP_BUTT),
            .round => @intToEnum(c.enum__cairo_line_cap, c.CAIRO_LINE_CAP_ROUND),
            .square => @intToEnum(c.enum__cairo_line_cap, c.CAIRO_LINE_CAP_SQUARE),
        };
    }
};

/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-line-join-t
pub const LineJoin = enum {
    miter = c.CAIRO_LINE_JOIN_MITER,
    round = c.CAIRO_LINE_JOIN_ROUND,
    bevel = c.CAIRO_LINE_JOIN_BEVEL,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_line_join) LineJoin {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_LINE_JOIN_MITER => LineJoin.miter,
            c.CAIRO_LINE_JOIN_ROUND => LineJoin.round,
            c.CAIRO_LINE_JOIN_BEVEL => LineJoin.bevel,
            else => std.debug.panic("cairo_line_join_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: LineJoin) c.enum__cairo_line_join {
        return switch (self) {
            .miter => @intToEnum(c.enum__cairo_line_join, c.CAIRO_LINE_JOIN_MITER),
            .round => @intToEnum(c.enum__cairo_line_join, c.CAIRO_LINE_JOIN_ROUND),
            .bevel => @intToEnum(c.enum__cairo_line_join, c.CAIRO_LINE_JOIN_BEVEL),
        };
    }
};

/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-operator-t
pub const Operator = enum {
    clear = c.CAIRO_OPERATOR_CLEAR,
    source = c.CAIRO_OPERATOR_SOURCE,
    over = c.CAIRO_OPERATOR_OVER,
    in = c.CAIRO_OPERATOR_IN,
    out = c.CAIRO_OPERATOR_OUT,
    atop = c.CAIRO_OPERATOR_ATOP,
    dest = c.CAIRO_OPERATOR_DEST,
    dest_over = c.CAIRO_OPERATOR_DEST_OVER,
    dest_in = c.CAIRO_OPERATOR_DEST_IN,
    dest_out = c.CAIRO_OPERATOR_DEST_OUT,
    dest_atop = c.CAIRO_OPERATOR_DEST_ATOP,
    xor = c.CAIRO_OPERATOR_XOR,
    add = c.CAIRO_OPERATOR_ADD,
    saturate = c.CAIRO_OPERATOR_SATURATE,
    multiply = c.CAIRO_OPERATOR_MULTIPLY,
    screen = c.CAIRO_OPERATOR_SCREEN,
    overlay = c.CAIRO_OPERATOR_OVERLAY,
    darken = c.CAIRO_OPERATOR_DARKEN,
    lighten = c.CAIRO_OPERATOR_LIGHTEN,
    color_dodge = c.CAIRO_OPERATOR_COLOR_DODGE,
    color_burn = c.CAIRO_OPERATOR_COLOR_BURN,
    hard_light = c.CAIRO_OPERATOR_HARD_LIGHT,
    soft_light = c.CAIRO_OPERATOR_SOFT_LIGHT,
    difference = c.CAIRO_OPERATOR_DIFFERENCE,
    exclusion = c.CAIRO_OPERATOR_EXCLUSION,
    hsl_hue = c.CAIRO_OPERATOR_HSL_HUE,
    hsl_saturation = c.CAIRO_OPERATOR_HSL_SATURATION,
    hsl_color = c.CAIRO_OPERATOR_HSL_COLOR,
    hsl_luminosity = c.CAIRO_OPERATOR_HSL_LUMINOSITY,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_operator) Operator {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_OPERATOR_CLEAR => Operator.clear,
            c.CAIRO_OPERATOR_SOURCE => Operator.source,
            c.CAIRO_OPERATOR_OVER => Operator.over,
            c.CAIRO_OPERATOR_IN => Operator.in,
            c.CAIRO_OPERATOR_OUT => Operator.out,
            c.CAIRO_OPERATOR_ATOP => Operator.atop,
            c.CAIRO_OPERATOR_DEST => Operator.dest,
            c.CAIRO_OPERATOR_DEST_OVER => Operator.over,
            c.CAIRO_OPERATOR_DEST_IN => Operator.dest_in,
            c.CAIRO_OPERATOR_DEST_OUT => Operator.dest_out,
            c.CAIRO_OPERATOR_DEST_ATOP => Operator.dest_atop,
            c.CAIRO_OPERATOR_XOR => Operator.xor,
            c.CAIRO_OPERATOR_ADD => Operator.add,
            c.CAIRO_OPERATOR_SATURATE => Operator.saturate,
            c.CAIRO_OPERATOR_MULTIPLY => Operator.multiply,
            c.CAIRO_OPERATOR_SCREEN => Operator.screen,
            c.CAIRO_OPERATOR_OVERLAY => Operator.overlay,
            c.CAIRO_OPERATOR_DARKEN => Operator.darken,
            c.CAIRO_OPERATOR_LIGHTEN => Operator.lighten,
            c.CAIRO_OPERATOR_COLOR_BURN => Operator.color_burn,
            c.CAIRO_OPERATOR_COLOR_DODGE => Operator.color_dodge,
            c.CAIRO_OPERATOR_HARD_LIGHT => Operator.hard_light,
            c.CAIRO_OPERATOR_SOFT_LIGHT => Operator.soft_light,
            c.CAIRO_OPERATOR_DIFFERENCE => Operator.difference,
            c.CAIRO_OPERATOR_EXCLUSION => Operator.exclusion,
            c.CAIRO_OPERATOR_HSL_HUE => Operator.hsl_hue,
            c.CAIRO_OPERATOR_HSL_SATURATION => Operator.hsl_saturation,
            c.CAIRO_OPERATOR_HSL_COLOR => Operator.hsl_color,
            c.CAIRO_OPERATOR_HSL_LUMINOSITY => Operator.hsl_luminosity,
            else => std.debug.panic("cairo_operator_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: Operator) c.enum__cairo_operator {
        return switch (self) {
            .clear => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_CLEAR),
            .source => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_SOURCE),
            .over => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_OVER),
            .in => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_IN),
            .out => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_IN),
            .atop => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_ATOP),
            .dest => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_DEST),
            .dest_over => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_DEST_OVER),
            .dest_in => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_DEST_IN),
            .dest_out => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_DEST_OUT),
            .dest_atop => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_DEST_ATOP),
            .xor => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_XOR),
            .add => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_ADD),
            .saturate => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_SATURATE),
            .multiply => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_MULTIPLY),
            .screen => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_SCREEN),
            .overlay => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_OVERLAY),
            .darken => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_DARKEN),
            .lighten => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_LIGHTEN),
            .color_burn => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_COLOR_BURN),
            .color_dodge => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_COLOR_DODGE),
            .hard_light => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_HARD_LIGHT),
            .soft_light => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_SOFT_LIGHT),
            .difference => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_DIFFERENCE),
            .exclusion => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_EXCLUSION),
            .hsl_hue => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_HSL_HUE),
            .hsl_saturation => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_HSL_SATURATION),
            .hsl_color => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_HSL_COLOR),
            .hsl_luminosity => @intToEnum(c.enum__cairo_operator, c.CAIRO_OPERATOR_HSL_LUMINOSITY),
        };
    }
};

/// https://cairographics.org/manual/cairo-Paths.html#cairo-path-data-type-t
pub const PathDataType = enum {
    move_to = c.CAIRO_PATH_MOVE_TO,
    line_to = c.CAIRO_PATH_LINE_TO,
    curve_to = c.CAIRO_PATH_CURVE_TO,
    close_path = c.CAIRO_PATH_CLOSE_PATH,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_path_data_type) PathDataType {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_PATH_MOVE_TO => PathDataType.move_to,
            c.CAIRO_PATH_LINE_TO => PathDataType.line_to,
            c.CAIRO_PATH_CURVE_TO => PathDataType.curve_to,
            c.CAIRO_PATH_CLOSE_PATH => PathDataType.close_path,
            else => std.debug.panic("cairo_path_data_type_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: PathDataType) c.enum__cairo_path_data_type {
        return switch (self) {
            .move_to => @intToEnum(c.enum__cairo_path_data_type, c.CAIRO_PATH_MOVE_TO),
            .line_to => @intToEnum(c.enum__cairo_path_data_type, c.CAIRO_PATH_LINE_TO),
            .curve_to => @intToEnum(c.enum__cairo_path_data_type, c.CAIRO_PATH_CURVE_TO),
            .close_path => @intToEnum(c.enum__cairo_path_data_type, c.CAIRO_PATH_CLOSE_PATH),
        };
    }
};

/// https://cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-type-t
pub const PatternType = enum {
    solid = c.CAIRO_PATTERN_TYPE_SOLID,
    surface = c.CAIRO_PATTERN_TYPE_SURFACE,
    linear = c.CAIRO_PATTERN_TYPE_LINEAR,
    radial = c.CAIRO_PATTERN_TYPE_RADIAL,
    mesh = c.CAIRO_PATTERN_TYPE_MESH,
    raster_source = c.CAIRO_PATTERN_TYPE_RASTER_SOURCE,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_pattern_type) PatternType {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_PATTERN_TYPE_SOLID => PatternType.solid,
            c.CAIRO_PATTERN_TYPE_SURFACE => PatternType.surface,
            c.CAIRO_PATTERN_TYPE_LINEAR => PatternType.linear,
            c.CAIRO_PATTERN_TYPE_RADIAL => PatternType.radial,
            c.CAIRO_PATTERN_TYPE_MESH => PatternType.mesh,
            c.CAIRO_PATTERN_TYPE_RASTER_SOURCE => PatternType.raster_source,
            else => std.debug.panic("cairo_pattern_type_t member {} not handled.", .{c_integer}),
        };
    }
};

/// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-metadata-t
pub const PdfMetadata = enum {
    title = c.CAIRO_PDF_METADATA_TITLE,
    author = c.CAIRO_PDF_METADATA_AUTHOR,
    subject = c.CAIRO_PDF_METADATA_SUBJECT,
    keywords = c.CAIRO_PDF_METADATA_KEYWORDS,
    creator = c.CAIRO_PDF_METADATA_CREATOR,
    create_date = c.CAIRO_PDF_METADATA_CREATE_DATE,
    mod_date = c.CAIRO_PDF_METADATA_MOD_DATE,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_pdf_metadata) PdfMetadata {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_PDF_METADATA_TITLE => PdfMetadata.title,
            c.CAIRO_PDF_METADATA_AUTHOR => PdfMetadata.author,
            c.CAIRO_PDF_METADATA_SUBJECT => PdfMetadata.subject,
            c.CAIRO_PDF_METADATA_KEYWORDS => PdfMetadata.keywords,
            c.CAIRO_PDF_METADATA_CREATOR => PdfMetadata.creator,
            c.CAIRO_PDF_METADATA_CREATE_DATE => PdfMetadata.create_date,
            c.CAIRO_PDF_METADATA_MOD_DATE => PdfMetadata.mod_date,
            else => std.debug.panic("cairo_pdf_metadata_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCairoEnum(self: PdfMetadata) c.enum__cairo_pdf_metadata {
        return switch (self) {
            .title => @intToEnum(c.enum__cairo_pdf_metadata, c.CAIRO_PDF_METADATA_TITLE),
            .author => @intToEnum(c.enum__cairo_pdf_metadata, c.CAIRO_PDF_METADATA_AUTHOR),
            .subject => @intToEnum(c.enum__cairo_pdf_metadata, c.CAIRO_PDF_METADATA_SUBJECT),
            .keywords => @intToEnum(c.enum__cairo_pdf_metadata, c.CAIRO_PDF_METADATA_KEYWORDS),
            .creator => @intToEnum(c.enum__cairo_pdf_metadata, c.CAIRO_PDF_METADATA_CREATOR),
            .create_date => @intToEnum(c.enum__cairo_pdf_metadata, c.CAIRO_PDF_METADATA_CREATE_DATE),
            .mod_date => @intToEnum(c.enum__cairo_pdf_metadata, c.CAIRO_PDF_METADATA_MOD_DATE),
        };
    }
};

/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-mode-t
pub const ScriptMode = enum {
    ascii = c.CAIRO_SCRIPT_MODE_ASCII,
    binary = c.CAIRO_SCRIPT_MODE_BINARY,

    pub fn fromCairoEnum(c_enum: anytype) ScriptMode {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            0 => ScriptMode.ascii,
            1 => ScriptMode.binary,
            else => std.debug.panic("cairo_script_mode_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn toCInt(self: ScriptMode) c_int {
        return switch (self) {
            .ascii => c.CAIRO_SCRIPT_MODE_ASCII,
            .binary => c.CAIRO_SCRIPT_MODE_BINARY,
        };
    }
};

/// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-type-t
pub const SurfaceType = enum {
    image = c.CAIRO_SURFACE_TYPE_IMAGE,
    pdf = c.CAIRO_SURFACE_TYPE_PDF,
    ps = c.CAIRO_SURFACE_TYPE_PS,
    xlib = c.CAIRO_SURFACE_TYPE_XLIB,
    xcb = c.CAIRO_SURFACE_TYPE_XCB,
    glitz = c.CAIRO_SURFACE_TYPE_GLITZ,
    quartz = c.CAIRO_SURFACE_TYPE_QUARTZ,
    win32 = c.CAIRO_SURFACE_TYPE_WIN32,
    beos = c.CAIRO_SURFACE_TYPE_BEOS,
    directfb = c.CAIRO_SURFACE_TYPE_DIRECTFB,
    svg = c.CAIRO_SURFACE_TYPE_SVG,
    os2 = c.CAIRO_SURFACE_TYPE_OS2,
    win32_printing = c.CAIRO_SURFACE_TYPE_WIN32_PRINTING,
    quartz_image = c.CAIRO_SURFACE_TYPE_QUARTZ_IMAGE,
    script = c.CAIRO_SURFACE_TYPE_SCRIPT,
    qt = c.CAIRO_SURFACE_TYPE_QT,
    recording = c.CAIRO_SURFACE_TYPE_RECORDING,
    vg = c.CAIRO_SURFACE_TYPE_VG,
    gl = c.CAIRO_SURFACE_TYPE_GL,
    drm = c.CAIRO_SURFACE_TYPE_DRM,
    tee = c.CAIRO_SURFACE_TYPE_TEE,
    xml = c.CAIRO_SURFACE_TYPE_XML,
    skia = c.CAIRO_SURFACE_TYPE_SKIA,
    subsurface = c.CAIRO_SURFACE_TYPE_SUBSURFACE,
    cogl = c.CAIRO_SURFACE_TYPE_COGL,

    pub fn fromCairoEnum(c_enum: c.enum__cairo_surface_type) SurfaceType {
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_SURFACE_TYPE_IMAGE => SurfaceType.image,
            c.CAIRO_SURFACE_TYPE_PDF => SurfaceType.pdf,
            c.CAIRO_SURFACE_TYPE_PS => SurfaceType.ps,
            c.CAIRO_SURFACE_TYPE_XLIB => SurfaceType.xlib,
            c.CAIRO_SURFACE_TYPE_XCB => SurfaceType.xcb,
            c.CAIRO_SURFACE_TYPE_GLITZ => SurfaceType.glitz,
            c.CAIRO_SURFACE_TYPE_QUARTZ => SurfaceType.quartz,
            c.CAIRO_SURFACE_TYPE_WIN32 => SurfaceType.win32,
            c.CAIRO_SURFACE_TYPE_BEOS => SurfaceType.beos,
            c.CAIRO_SURFACE_TYPE_DIRECTFB => SurfaceType.directfb,
            c.CAIRO_SURFACE_TYPE_SVG => SurfaceType.svg,
            c.CAIRO_SURFACE_TYPE_OS2 => SurfaceType.os2,
            c.CAIRO_SURFACE_TYPE_WIN32_PRINTING => SurfaceType.win32_printing,
            c.CAIRO_SURFACE_TYPE_QUARTZ_IMAGE => SurfaceType.quartz_image,
            c.CAIRO_SURFACE_TYPE_SCRIPT => SurfaceType.script,
            c.CAIRO_SURFACE_TYPE_QT => SurfaceType.qt,
            c.CAIRO_SURFACE_TYPE_RECORDING => SurfaceType.recording,
            c.CAIRO_SURFACE_TYPE_VG => SurfaceType.vg,
            c.CAIRO_SURFACE_TYPE_GL => SurfaceType.gl,
            c.CAIRO_SURFACE_TYPE_DRM => SurfaceType.drm,
            c.CAIRO_SURFACE_TYPE_TEE => SurfaceType.tee,
            c.CAIRO_SURFACE_TYPE_XML => SurfaceType.xml,
            c.CAIRO_SURFACE_TYPE_SKIA => SurfaceType.skia,
            c.CAIRO_SURFACE_TYPE_SUBSURFACE => SurfaceType.subsurface,
            c.CAIRO_SURFACE_TYPE_COGL => SurfaceType.cogl,
            else => std.debug.panic("cairo_surface_type_t member {} not handled.", .{c_integer}),
        };
    }
};

/// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-unit-t
pub const Unit = enum {
    user = c.CAIRO_SVG_UNIT_USER,
    em = c.CAIRO_SVG_UNIT_EM,
    ex = c.CAIRO_SVG_UNIT_EX,
    px = c.CAIRO_SVG_UNIT_PX,
    in = c.CAIRO_SVG_UNIT_IN,
    cm = c.CAIRO_SVG_UNIT_CM,
    mm = c.CAIRO_SVG_UNIT_MM,
    pt = c.CAIRO_SVG_UNIT_PT,
    pc = c.CAIRO_SVG_UNIT_PC,
    percent = c.CAIRO_SVG_UNIT_PERCENT,

    pub fn fromCairoEnum(c_enum: anytype) Unit { // there is no c.enum__cairo_unit
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_SVG_UNIT_USER => Unit.user,
            c.CAIRO_SVG_UNIT_EM => Unit.em,
            c.CAIRO_SVG_UNIT_EX => Unit.ex,
            c.CAIRO_SVG_UNIT_PX => Unit.px,
            c.CAIRO_SVG_UNIT_IN => Unit.in,
            c.CAIRO_SVG_UNIT_CM => Unit.cm,
            c.CAIRO_SVG_UNIT_MM => Unit.mm,
            c.CAIRO_SVG_UNIT_PT => Unit.pt,
            c.CAIRO_SVG_UNIT_PC => Unit.pc,
            c.CAIRO_SVG_UNIT_PERCENT => Unit.percent,
            else => std.debug.panic("cairo_surface_type_t member {} not handled.", .{c_integer}),
        };
    }
};
