const std = @import("std");
const c = @import("c.zig");

usingnamespace @import("enums.zig");

usingnamespace @import("surfaces/surface.zig");

usingnamespace @import("drawing/pattern.zig");
usingnamespace @import("drawing/text.zig");
usingnamespace @import("drawing/context.zig");

usingnamespace @import("fonts/scaled_font.zig");

usingnamespace @import("utilities/matrix.zig");

pub const Error = @import("errors.zig").Error;
