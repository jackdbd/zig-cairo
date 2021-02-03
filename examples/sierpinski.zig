const std = @import("std");
const builtin = @import("builtin");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

const m_1_sqrt_3: f64 = 0.577359269; // 1.0 / std.math.sqrt(3)

fn triangle(cr: *cairo.Context, size: f64) void {
    cr.moveTo(0, 0);
    cr.lineTo(size, 0);
    cr.lineTo(size * 0.5, size * m_1_sqrt_3);

    const half = size * 0.5;
    if (half >= 4) {
        triangle(cr, half);
        cr.save();
        cr.translate(half, 0);
        triangle(cr, half);
        cr.restore();
        cr.save();
        cr.translate(half * 0.5, half * m_1_sqrt_3);
        triangle(cr, half);
        cr.restore();
    }
}

/// Zig porting of this example in C.
/// https://github.com/freedesktop/cairo/blob/master/perf/micro/sierpinski.c
fn drawSierpinski(cr: *cairo.Context, width: f64, height: f64) void {
    const t_height = height / 2.0;
    const t_width = t_height / m_1_sqrt_3;

    cr.setSourceRgb(1, 1, 1); // white
    cr.paint();

    cr.setSourceRgb(0, 0, 0); // black
    cr.setLineWidth(1.0);

    cr.save();
    triangle(cr, t_width);
    cr.translate(0, height);
    cr.scale(1, -1);
    triangle(cr, t_width);
    cr.stroke();
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
    drawSierpinski(&cr, @intToFloat(f64, width), @intToFloat(f64, height));
    _ = surface.writeToPng("examples/generated/sierpinski.png");
}
