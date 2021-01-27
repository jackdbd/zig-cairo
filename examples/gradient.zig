const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/gradient/
fn gradient(cr: *cairo.Context) !void {
    var pattern = try cairo.Pattern.createLinear(0.0, 0.0, 0.0, 256.0);
    defer pattern.destroy();

    try pattern.addColorStopRgba(1, 0, 0, 0, 1);
    try pattern.addColorStopRgba(0, 1, 1, 1, 1);
    cr.rectangle(0, 0, 256, 256);
    cr.setSource(&pattern);
    cr.fill();

    pattern = try cairo.Pattern.createRadial(115.2, 102.4, 25.6, 102.4, 102.4, 128.0);

    try pattern.addColorStopRgba(0, 1, 1, 1, 1);
    try pattern.addColorStopRgba(1, 0, 0, 0, 1);
    cr.setSource(&pattern);
    cr.arc(128.0, 128.0, 76.8, 0, 2 * pi);
    cr.fill();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    // std.debug.print("gradient example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try gradient(&cr);
    _ = surface.writeToPng("examples/generated/gradient.png");
}
