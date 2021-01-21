//! Font face at particular size and options.
//! https://cairographics.org/manual/cairo-cairo-scaled-font-t.html
const std = @import("std");
const c = @import("../c.zig");

pub var te: c.cairo_text_extents_t = undefined;

/// https://cairographics.org/manual/cairo-cairo-scaled-font-t.html#cairo-text-extents-t
pub const TextExtents = struct {
    x_bearing: f64,
    y_bearing: f64,
    width: f64,
    height: f64,
    x_advance: f64,
    y_advance: f64,
};
