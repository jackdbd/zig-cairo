const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/image/
fn image(cr: *cairo.Context) !void {
    var surface = try cairo.Surface.createFromPng("data/romedalen.png");
    defer surface.destroy();

    const w = try surface.getWidth();
    const h = try surface.getHeight();

    cr.translate(128.0, 128.0);
    cr.rotate(45 * pi / 180.0);
    cr.scale(256.0 / @intToFloat(f64, w), 256.0 / @intToFloat(f64, h));
    cr.translate(-0.5 * @intToFloat(f64, w), -0.5 * @intToFloat(f64, h));

    cr.setSourceSurface(&surface, 0, 0);
    cr.paint();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    // std.debug.print("image example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try image(&cr);
    _ = surface.writeToPng("examples/generated/image.png");
}
