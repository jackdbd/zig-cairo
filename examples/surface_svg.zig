const std = @import("std");
const cairo = @import("cairo");
const render = @import("render.zig");

pub fn main() !void {
    std.debug.print("Example with the Cairo surface SVG backend\n", .{});
    const width_pt: f64 = 640;
    const height_pt: f64 = 480;

    var surface = try cairo.Surface.svg("examples/generated/test-image.svg", width_pt, height_pt);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    render.testImage(&cr, width_pt, height_pt);

    var surface2 = try cairo.Surface.svg("examples/generated/line-chart.svg", width_pt, height_pt);
    defer surface2.destroy();

    var cr2 = try cairo.Context.create(&surface2);
    defer cr2.destroy();

    render.lineChart(&cr2, width_pt, height_pt);
}
