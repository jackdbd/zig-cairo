const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/clip_image/
fn clipImage(cr: *cairo.Context) !void {
    cr.setSourceRgb(0.0, 0.0, 0.0); // black

    var image = try cairo.Surface.createFromPng("data/romedalen.png");
    defer image.destroy();

    const w = try image.getWidth();
    const h = try image.getHeight();
    // std.debug.print("Original PNG image dimensions: {}x{} px\n", .{ w, h });

    cr.arc(128.0, 128.0, 76.8, 0, 2 * pi);
    cr.clip();
    cr.newPath(); // path not consumed by cr.clip()

    cr.scale(256.0 / @intToFloat(f64, w), 256.0 / @intToFloat(f64, h));
    cr.setSourceSurface(&image, 0, 0);
    cr.paint();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    // std.debug.print("clip_image example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try clipImage(&cr);
    _ = surface.writeToPng("examples/generated/clip_image.png");
}
