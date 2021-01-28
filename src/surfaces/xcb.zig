//! Cairo surface XCB backend.
//! The XCB surface is used to render cairo graphics to X Window System windows
//! and pixmaps using the XCB library.
//! https://www.cairographics.org/manual/cairo-XCB-Surfaces.html
const c = @import("../c.zig");
const Device = @import("device.zig").Device;
const Error = @import("../errors.zig").Error;

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-device-debug-cap-xrender-version
pub fn deviceDebugCapXrenderVersion() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-device-debug-cap-xshm-version
pub fn deviceDebugCapXshmVersion() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-device-get-connection
pub fn deviceGetConnection(device: Device) !*c.xcb_connection_t {
    // TODO: check whether Cairo guarantees that cairo_xcb_device_get_connection
    // always return a valid pointer or not.
    var c_ptr = c.cairo_xcb_device_get_connection(device.device);
    if (c_ptr == null) return Error.NullPointer;
    return c_ptr.?;
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-device-debug-get-precision
pub fn deviceDebugGetPrecision() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-device-debug-set-precision
pub fn deviceDebugSetPrecision() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-surface-create
pub fn surfaceCreate(conn: ?*c.struct_xcb_connection_t, drawable: u32, visual: ?*c.struct_xcb_visualtype_t, width: u16, height: u16) !*c.struct__cairo_surface {
    // cairo_xcb_surface_create always returns a valid pointer, but it will
    // return a pointer to a "nil" surface if an error such as out of memory
    // occurs. You can use cairo_surface_status() to check for this.
    return c.cairo_xcb_surface_create(conn, drawable, visual, width, height).?;
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-surface-create-for-bitmap
pub fn surfaceCreateForBitmap() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-surface-create-with-xrender-format
pub fn surfaceCreateWithXrenderFormat() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-surface-set-drawable
pub fn surfaceSetDrawable() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-XCB-Surfaces.html#cairo-xcb-surface-set-size
pub fn surfaceSetSize(surface: *c.struct__cairo_surface, width: u16, height: u16) void {
    c.cairo_xcb_surface_set_size(surface, width, height);
}
