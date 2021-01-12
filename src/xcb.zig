const std = @import("std");
const c = @import("c.zig");

pub const XCB_WINDOW_CLASS_INPUT_OUTPUT: u16 = @as(u16, c.XCB_WINDOW_CLASS_INPUT_OUTPUT);
pub const XCB_COPY_FROM_PARENT = c.XCB_COPY_FROM_PARENT;

// TODO: define all XCB errors
/// https://xcb.freedesktop.org/manual/structxcb__generic__error__t.html
pub const Error = error{CannotConnectToXServer};

/// xcb_window_class_t
/// https://xcb.freedesktop.org/manual/group__XCB____API.html
pub const WindowClass = enum {
    CopyFromParent,
    InputOutput,
    InputOnly,
};

/// https://xcb.freedesktop.org/PublicApi/
pub const Xcb = struct {
    // An xcb_connection_t is an opaque structure containing all data that XCB
    // needs to communicate with an X server. The structure is defined in xcbint.h.
    conn: *c.struct_xcb_connection_t,

    const Self = @This();

    pub fn connect(display: ?[*]const u8, screen: ?[*]c_int) Error!Self {
        const conn = c.xcb_connect(display, screen);
        if (conn == null) return error.CannotConnectToXServer;
        // std.debug.print("XCB connection: {}\n", .{conn});
        return Self{ .conn = conn.? };
    }

    pub fn disconnect(self: *Self) void {
        // std.debug.print("XCB disconnect\n", .{});
        c.xcb_disconnect(self.conn);
    }

    pub fn generateId(self: *const Self) u32 {
        const window_id = c.xcb_generate_id(self.conn);
        return window_id;
    }

    pub fn setupRootsIterator(self: *Self) *c.struct_xcb_screen_t {
        // we need to cast from unknown length pointer to single pointer because
        // otherwise the zig compiler complains about s not supporting field access.
        const s = @ptrCast(*c.xcb_screen_t, c.xcb_setup_roots_iterator(c.xcb_get_setup(self.conn)).data);
        return s;
    }

    /// In XCB, a Graphics Context is, as a window, characterized by an Id.
    /// https://xcb.freedesktop.org/tutorial/basicwindowsanddrawing/
    pub fn createWindow(self: *Self, depth: u8, window_id: u32, root: u32, x: i16, y: i16, width: u16, height: u16, border_width: u16, win_class: u16, root_visual: u32, mask: comptime u32, values: anytype) void {
        const win = c.xcb_create_window(self.conn, depth, window_id, root, x, y, width, height, border_width, win_class, root_visual, mask, values);
        // std.debug.print("XCB createWindow: {}\n", .{win});
    }

    pub fn mapWindow(self: *Self, window_id: u32) void {
        const x = c.xcb_map_window(self.conn, window_id);
        // std.debug.print("XCB mapWindow: {}\n", .{x});
    }

    pub fn flush(self: *Self) void {
        const x = c.xcb_flush(self.conn);
        // std.debug.print("XCB flush: {}\n", .{x});
    }

    pub fn waitForEvent(self: *Self) *c.xcb_generic_event_t {
        // xcb_generic_event_t *event;
        return c.xcb_wait_for_event(self.conn);
    }
};

/// Get the Id of the visual of a screen.
/// https://xcb.freedesktop.org/xlibtoxcbtranslationguide/
pub fn lookup_visual(s: *c.xcb_screen_t, visual: c.xcb_visualid_t) ?*c.xcb_visualtype_t {
    var depth_iter = c.xcb_screen_allowed_depths_iterator(s);
    // std.debug.print("TYPE INFO depth_iter: {}\n", .{@typeInfo(@TypeOf(depth_iter))});
    while (depth_iter.rem != 0) {
        var visual_iter = c.xcb_depth_visuals_iterator(depth_iter.data);
        while (visual_iter.rem != 0) {
            if (@ptrCast(*c.xcb_visualtype_t, visual_iter.data).visual_id == visual) {
                return visual_iter.data;
            }
            c.xcb_visualtype_next(&visual_iter);
        }
        c.xcb_depth_next(&depth_iter);
    }
    return null;
}
