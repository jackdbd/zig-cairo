//! Errors that can occurr when using Cairo
// TODO: move these ones to their respective modules
const std = @import("std");
const c = @import("c.zig");

/// Possible return values for cairo_region_status ()
/// https://www.cairographics.org/manual/cairo-Regions.html#cairo-region-status
pub const RegionStatus = enum {
    Success,
    NoMemory,
};

/// Possible return values for cairo_scaled_font_status ()
/// https://www.cairographics.org/manual/cairo-cairo-scaled-font-t.html#cairo-scaled-font-status
pub const ScaledFontStatus = enum {
    Success,
    NoMemory,
};

/// Possible return values for cairo_font_face_status ()
/// https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-status
pub const FontFaceStatus = enum {
    Success,
    NoMemory,
};
