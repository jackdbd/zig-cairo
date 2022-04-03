const std = @import("std");
const cairo = @import("cairo");
const xcb = @import("xcb");
const render = @import("render.zig");

pub fn main() !void {
    var display: ?[*]const u8 = null;
    var screen: ?[*]c_int = null;

    var conn = try xcb.Xcb.connect(display, screen);
    defer conn.disconnect();

    var s = conn.setupRootsIterator();
    const window_id = conn.generateId();
    const x: i16 = 0;
    const y: i16 = 0;
    const window_width: u16 = 640;
    const window_height: u16 = 480;
    const border_width: u16 = 0;
    const win_class = xcb.XCB_WINDOW_CLASS_INPUT_OUTPUT;
    const depth = xcb.XCB_COPY_FROM_PARENT;
    const mask = 0;
    const values = null;

    var xcb_cookie = conn.createWindow(depth, window_id, s.root, x, y, window_width, window_height, border_width, win_class, s.root_visual, mask, values);
    std.log.debug("xcb_cookie after conn.createWindow {}", .{xcb_cookie});
    xcb_cookie = conn.mapWindow(window_id);
    std.log.debug("xcb_cookie after conn.mapWindow {}", .{xcb_cookie});
    const c_integer = conn.flush();
    std.log.debug("c_integer {}", .{c_integer});
    const vis = xcb.lookup_visual(s, s.root_visual);

    var surface = try cairo.Surface.xcb(conn.c_ptr, window_id, vis, window_width, window_height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    render.testImage(&cr, window_width, window_height);
    _ = conn.flush();
    std.time.sleep(1e9);

    render.lineChart(&cr, window_width, window_height);
    _ = conn.flush();
    std.time.sleep(1e9);
}
