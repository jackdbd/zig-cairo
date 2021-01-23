const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/rounded_rectangle/
fn roundedRectangle(cr: *cairo.Context) void {
    const x: f64 = 25.6;
    const y: f64 = 25.6;
    const width: f64 = 204.8;
    const height: f64 = 204.8;
    const aspect: f64 = 1.0;
    const corner_radius: f64 = 10.0;

    const radius = corner_radius / aspect;
    const degrees = pi / 180.0;

    cr.newSubPath();
    cr.arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
    cr.arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
    cr.arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
    cr.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
    cr.closePath();

    cr.setSourceRgb(0.5, 0.5, 1);
    cr.fillPreserve();
    cr.setSourceRgba(0.5, 0, 0, 0.5);
    cr.setLineWidth(10.0);
    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    // std.debug.print("rounded_rectangle example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    roundedRectangle(&cr);
    _ = surface.writeToPng("examples/generated/rounded_rectangle.png");
}
