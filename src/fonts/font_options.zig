//! How a font should be rendered.
//! https://cairographics.org/manual/cairo-cairo-font-options-t.html
const std = @import("std");
const log = std.log;
const c = @import("../c.zig");
const Error = @import("../errors.zig").Error;
const enums = @import("../enums.zig");

const Status = enum {
    Success = c.CAIRO_STATUS_SUCCESS, // 0
};

pub const FontOptions = struct {
    c_ptr: *c.struct__cairo_font_options,

    const Self = @This();

    /// https://cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-create
    pub fn create() !Self {
        const c_ptr = c.cairo_font_options_create();
        if (c_ptr == null) return Error.NullPointer;
        // try checkStatus(cr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_font_options_destroy(self.c_ptr);
    }

    pub fn setHintStyle(self: *Self, hint_style: HintStyle) void {
        const c_integer = @enumToInt(hint_style);
        const c_enum = @intToEnum(c.enum__cairo_hint_style, c_integer);
        c.cairo_font_options_set_hint_style(self.c_ptr, c_enum);
    }

    pub fn setHintMetrics(self: *Self, hint_metrics: HintMetrics) void {
        const c_integer = @enumToInt(hint_metrics);
        const c_enum = @intToEnum(c.enum__cairo_hint_metrics, c_integer);
        c.cairo_font_options_set_hint_metrics(self.c_ptr, c_enum);
    }

    /// https://cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-status
    pub fn status(c_ptr: *c.struct__cairo_font_options) !Status {
        const c_enum = c.cairo_font_options_status(c_ptr);
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_STATUS_NO_MEMORY => Error.NoMemory,
            c.CAIRO_STATUS_SUCCESS => Status.Success,
            else => unreachable,
        };
    }
};

/// https://cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-hint-metrics-t
pub const HintMetrics = enum {
    Default = c.CAIRO_HINT_METRICS_DEFAULT,
    Off = c.CAIRO_HINT_METRICS_OFF,
    On = c.CAIRO_HINT_METRICS_ON,
};

/// https://cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-hint-style-t
pub const HintStyle = enum {
    Default = c.CAIRO_HINT_STYLE_DEFAULT,
    None = c.CAIRO_HINT_STYLE_NONE,
    Slight = c.CAIRO_HINT_STYLE_SLIGHT,
    Medium = c.CAIRO_HINT_STYLE_MEDIUM,
    Full = c.CAIRO_HINT_STYLE_FULL,
};
