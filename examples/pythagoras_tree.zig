const std = @import("std");
const builtin = @import("builtin");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

const m_sqrt_2 = std.math.sqrt(2.0);

// this function fails with cairo.Error.NoCurrentPoint if no current point is set
fn addRectangle(cr: *cairo.Context, size: f64) cairo.Error!void {
    var x: f64 = 0.0;
    var y: f64 = 0.0;

    if (size < 1) {
        return;
    }

    cr.getCurrentPoint(&x, &y);

    try cr.relMoveTo(-size / 2.0, -size / 2.0);
    try cr.relLineTo(size, 0);
    try cr.relLineTo(0, size);
    try cr.relLineTo(-size, 0);
    cr.closePath();

    cr.save();
    cr.translate(-size / 2.0, size);
    cr.moveTo(x, y);
    cr.rotate(pi / 4.0);
    try addRectangle(cr, size / m_sqrt_2);
    cr.restore();

    cr.save();
    cr.translate(size / 2.0, size);
    cr.moveTo(x, y);
    cr.rotate(-pi / 4.0);
    try addRectangle(cr, size / m_sqrt_2);
    cr.restore();
}

/// Zig porting of this example in C.
/// https://github.com/freedesktop/cairo/blob/master/perf/micro/pythagoras-tree.c
fn drawPythagorasTree(cr: *cairo.Context, width: f64, height: f64) cairo.Error!void {
    const size = 128.0;

    cr.save();
    cr.translate(0, height);
    cr.scale(1, -1);

    cr.moveTo(width / 2.0, size / 2.0);
    try addRectangle(cr, size);
    cr.setSourceRgb(0, 0, 0);
    cr.fill();
    cr.restore();
}

pub fn main() !void {
    const width: u16 = 400;
    const height: u16 = 400;
    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try drawPythagorasTree(&cr, @intToFloat(f64, width), @intToFloat(f64, height));
    _ = surface.writeToPng("examples/generated/pythagoras_tree.png");
}
