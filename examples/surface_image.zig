const std = @import("std");
const cairo = @import("cairo");
const render = @import("render.zig");

pub fn main() !void {
    const width: u16 = 640;
    const height: u16 = 480;
    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    render.testImage(&cr, width, height);
    _ = surface.writeToPng("examples/generated/test-image.png");

    render.lineChart(&cr, width, height);
    _ = surface.writeToPng("examples/generated/line-chart.png");
}
