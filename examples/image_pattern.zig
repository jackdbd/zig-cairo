const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/imagepattern/
fn imagePattern(cr: *cairo.Context) !void {
    var image = try cairo.Surface.createFromPng("data/romedalen.png");
    defer image.destroy();

    const w = try image.getWidth();
    const h = try image.getHeight();

    var pattern = try cairo.Pattern.createForSurface(&image);
    defer pattern.destroy();

    pattern.setExtend(cairo.Extend.Repeat);

    cr.translate(128.0, 128.0);
    cr.rotate(pi / 4.0);
    cr.scale(1.0 / @sqrt(2.0), 1.0 / std.math.sqrt(2.0));
    cr.translate(-128.0, -128.0);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const sx = @intToFloat(f64, w) / 256.0 * 5.0;
    const sy = @intToFloat(f64, h) / 256.0 * 5.0;
    var matrix = try cairo.Matrix.initScale(&arena.allocator, sx, sy);

    pattern.setMatrix(&matrix);

    cr.setSource(&pattern);
    cr.rectangle(0, 0, 256, 256);
    cr.fill();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("image_pattern example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.fromSurface(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try imagePattern(&cr);
    _ = surface.writeToPng("examples/generated/image_pattern.png");
}
