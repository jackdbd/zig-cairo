const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://github.com/pygobject/pycairo/blob/master/examples/pycairo_examples.ipynb
fn maskExample(cr: *cairo.Context) !void {
    var pattern = try cairo.Pattern.createLinear(0, 0, 256, 256);
    defer pattern.destroy();

    try pattern.addColorStopRgb(0, 0, 0.3, 0.8);
    try pattern.addColorStopRgb(1, 0, 0.8, 0.3);

    var mask = try cairo.Pattern.createRadial(128, 128, 64, 128, 128, 128);
    defer mask.destroy();

    try mask.addColorStopRgba(0, 0, 0, 0, 1);
    try mask.addColorStopRgba(0.5, 0, 0, 0, 0);

    cr.setSource(&pattern);
    cr.mask(&mask);
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try maskExample(&cr);
    _ = surface.writeToPng("examples/generated/mask.png");
}
