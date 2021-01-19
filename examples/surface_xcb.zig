const std = @import("std");
const cairo = @import("cairo");
const xcb = @import("xcb");
const render = @import("render.zig");

pub fn main() !void {
    std.debug.print("Example with the Cairo surface XCB backend\n", .{});

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

    _ = conn.createWindow(depth, window_id, s.root, x, y, window_width, window_height, border_width, win_class, s.root_visual, mask, values);
    _ = conn.mapWindow(window_id);
    _ = conn.flush();
    const vis = xcb.lookup_visual(s, s.root_visual);

    var surface = try cairo.Surface.xcb(conn.conn, window_id, vis, window_width, window_height);
    defer surface.destroy();

    var cr = try cairo.Context.fromSurface(&surface);
    defer cr.destroy();

    render.testImage(&cr, window_width, window_height);
    _ = conn.flush();
    std.time.sleep(1e9);

    render.lineChart(&cr, window_width, window_height);
    _ = conn.flush();
    std.time.sleep(1e9);
}
