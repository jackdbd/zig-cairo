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
    c_ptr: *c.struct_xcb_connection_t,

    const Self = @This();

    pub fn connect(display: ?[*]const u8, screen: ?[*]c_int) Error!Self {
        const c_ptr = c.xcb_connect(display, screen);
        if (c_ptr == null) return error.CannotConnectToXServer;
        return Self{ .c_ptr = c_ptr.? };
    }

    pub fn disconnect(self: *Self) void {
        c.xcb_disconnect(self.c_ptr);
    }

    pub fn generateId(self: *const Self) u32 {
        const window_id = c.xcb_generate_id(self.c_ptr);
        return window_id;
    }

    pub fn setupRootsIterator(self: *Self) *c.struct_xcb_screen_t {
        // we need to cast from unknown length pointer to single pointer because
        // otherwise the zig compiler complains about s not supporting field access.
        const s = @ptrCast(*c.xcb_screen_t, c.xcb_setup_roots_iterator(c.xcb_get_setup(self.c_ptr)).data);
        return s;
    }

    /// In XCB, a Graphics Context is, as a window, characterized by an Id.
    /// https://xcb.freedesktop.org/tutorial/basicwindowsanddrawing/
    pub fn createWindow(self: *Self, depth: u8, window_id: u32, root: u32, x: i16, y: i16, width: u16, height: u16, border_width: u16, win_class: u16, root_visual: u32, mask: u32, values: anytype) c.xcb_void_cookie_t {
        return c.xcb_create_window(self.c_ptr, depth, window_id, root, x, y, width, height, border_width, win_class, root_visual, mask, values);
        // orelse @panic("could not create a window");
    }

    pub fn mapWindow(self: *Self, window_id: u32) c.xcb_void_cookie_t {
        return c.xcb_map_window(self.c_ptr, window_id);
    }

    pub fn flush(self: *Self) c_int {
        return c.xcb_flush(self.c_ptr);
    }

    pub fn waitForEvent(self: *Self) *c.xcb_generic_event_t {
        // xcb_generic_event_t *event;
        return c.xcb_wait_for_event(self.c_ptr);
    }
};

/// Get the Id of the visual of a screen.
/// https://xcb.freedesktop.org/xlibtoxcbtranslationguide/
pub fn lookup_visual(s: *c.xcb_screen_t, visual: c.xcb_visualid_t) ?*c.xcb_visualtype_t {
    var depth_iter = c.xcb_screen_allowed_depths_iterator(s);
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
