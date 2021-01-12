//! Cairo device interface.
//! Devices are the abstraction Cairo employs for the rendering system used by a
//! cairo_surface_t.
const std = @import("std");
const c = @import("../c.zig");

/// A Cairo device is the interface to the underlying rendering system.
/// https://www.cairographics.org/manual/cairo-cairo-device-t.html
pub const Device = struct {
    device: *c.struct__cairo_device,
};
