const std = @import("std");
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/dash/
fn dash(cr: *cairo.Context) !void {
    cr.setSourceRgb(0.0, 0.0, 0.0); // black

    const offset: f64 = -50.0;

    // Option 1 ////////////////////////////////////////////////////////////////
    var dashes_arr = [_]f64{
        50.0, // ink
        10.0, // skip
        10.0, // ink
        10.0, // skip
    };
    cr.setDash(dashes_arr[0..], offset);

    // Option 2 ////////////////////////////////////////////////////////////////
    var dashes = std.ArrayList(f64).init(std.testing.allocator);
    defer dashes.deinit();
    try dashes.append(50.0); // ink
    try dashes.append(10.0); // skip
    try dashes.append(10.0); // ink
    try dashes.append(10.0); // skip
    cr.setDash(dashes.items, offset);
    ////////////////////////////////////////////////////////////////////////////

    cr.setLineWidth(10.0);

    cr.moveTo(128.0, 25.6);
    cr.lineTo(230.4, 230.4);
    try cr.relLineTo(-102.4, 0.0);
    cr.curveTo(51.2, 230.4, 51.2, 128.0, 128.0, 128.0);

    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try dash(&cr);
    _ = surface.writeToPng("examples/generated/dash.png");
}
