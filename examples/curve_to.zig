const std = @import("std");
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/curve_to/
fn curveTo(cr: *cairo.Context, width: usize, height: usize) void {
    const x: f64 = 25.6;
    const y: f64 = 128.0;

    const x1: f64 = 102.4;
    const y1: f64 = 230.4;
    const x2: f64 = 153.6;
    const y2: f64 = 25.6;
    const x3: f64 = 230.4;
    const y3: f64 = 128.0;

    cr.setSourceRgb(0.0, 0.0, 0.0); // black

    cr.moveTo(x, y);
    cr.curveTo(x1, y1, x2, y2, x3, y3);

    cr.setLineWidth(10.0);
    cr.stroke();

    cr.setSourceRgba(1, 0.2, 0.2, 0.6);
    cr.setLineWidth(6.0);

    cr.moveTo(x, y);
    cr.lineTo(x1, y1);

    cr.moveTo(x2, y2);
    cr.lineTo(x3, y3);

    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    // std.debug.print("curve_to example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    curveTo(&cr, width, height);
    _ = surface.writeToPng("examples/generated/curve_to.png");
}
