//! Cairo surface XCB backend.
//! The XCB surface is used to render cairo graphics to X Window System windows
//! and pixmaps using the XCB library.
//! https://www.cairographics.org/manual/cairo-XCB-Surfaces.html
const c = @import("../c.zig");
const Status = @import("../status.zig").Status;
const Device = @import("device.zig").Device;

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-surface-create
pub fn create(conn: ?*c.struct_xcb_connection_t, drawable: u32, visual: ?*c.struct_xcb_visualtype_t, width: u16, height: u16) !*c.struct__cairo_surface {
    var surface = c.cairo_xcb_surface_create(conn, drawable, visual, width, height);
    if (surface == null) return Status.NullPointer;
    return surface.?;
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-device-get-connection
pub fn getConnection(device: Device) !*c.xcb_connection_t {
    var conn = c.cairo_xcb_device_get_connection(device.device);
    if (conn == null) return Status.NullPointer;
    return conn.?;
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-surface-set-size
pub fn setSize(surface: *c.struct__cairo_surface, width: u16, height: u16) void {
    c.cairo_xcb_surface_set_size(surface, width, height);
}
