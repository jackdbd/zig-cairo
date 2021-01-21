const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/arc/
fn arc(cr: *cairo.Context) void {
    const xc: f64 = 128.0;
    const yc: f64 = 128.0;
    const radius: f64 = 100.0;
    // angles are specified in radians
    const angle1 = 45.0 * (pi / 180.0);
    const angle2 = 180.0 * (pi / 180.0);

    cr.setSourceRgb(0.0, 0.0, 0.0); // black

    cr.setLineWidth(10.0);
    cr.arc(xc, yc, radius, angle1, angle2);
    cr.stroke();

    // draw helping lines
    cr.setSourceRgba(1, 0.2, 0.2, 0.6);
    cr.arc(xc, yc, 10.0, 0, 2 * pi);
    cr.fill();
    cr.setLineWidth(6.0);
    cr.arc(xc, yc, radius, angle1, angle1);
    cr.lineTo(xc, yc);
    cr.arc(xc, yc, radius, angle2, angle2);
    cr.lineTo(xc, yc);
    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("arc example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    arc(&cr);
    _ = surface.writeToPng("examples/generated/arc.png");
}
