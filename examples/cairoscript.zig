//! Render these Cairo operations on a script.
const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");

pub fn main() !void {
    const OUTPUT_DEVICE_FILENAME = "examples/generated/cairoscript";
    const width: f64 = 640;
    const height: f64 = 480;
    var surface = try cairo.Surface.script(OUTPUT_DEVICE_FILENAME, cairo.Content.color, width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    try surface.writeComment("render a gray background");
    cr.setSourceRgb(0.93, 0.93, 0.93); // gray
    cr.paintWithAlpha(1.0);

    try surface.writeComment("render a red rectangle with a thick blue outline");
    cr.setSourceRgba(1, 0, 0, 0.95);
    cr.rectangle(0, 0, 256, 256);
    cr.fillPreserve();
    cr.setLineWidth(8.0);
    cr.setSourceRgb(0, 0, 1);
    cr.stroke();
}
