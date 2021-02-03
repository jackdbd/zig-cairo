//! zig-cairo: zig wrapper for Cairo

// Export c to allow calling the C Cairo API.
// For example, if you import zig-cairo with:
// const cairo = @import("cairo");
// you will be able to access the original C functions with cairo.c. (e.g.
// cairo.c.cairo_create(), cairo.c.cairo_surface_status())
pub const c = @import("c.zig");

usingnamespace @import("constants.zig");
usingnamespace @import("enums.zig");

usingnamespace @import("surfaces/surface.zig");

usingnamespace @import("drawing/path.zig");
usingnamespace @import("drawing/pattern.zig");
usingnamespace @import("drawing/tags_and_links.zig");
usingnamespace @import("drawing/text.zig");
usingnamespace @import("drawing/transformations.zig");
usingnamespace @import("drawing/context.zig");

usingnamespace @import("fonts/scaled_font.zig");
usingnamespace @import("fonts/font_options.zig");

usingnamespace @import("utilities/matrix.zig");
usingnamespace @import("utilities/error_handling.zig");
usingnamespace @import("utilities/version_information.zig");
