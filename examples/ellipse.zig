const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// Draw an ellipse.
/// x      - center x
/// y      - center y
/// width  - width of ellipse  (in x direction when angle=0)
/// height - height of ellipse (in y direction when angle=0)
/// angle  - angle in radians to rotate, clockwise
fn pathEllipse(cr: *cairo.Context, x: f64, y: f64, width: f64, height: f64, angle: f64) void {
    cr.save();
    cr.translate(x, y);
    cr.rotate(angle);
    cr.scale(width / 2.0, height / 2.0);
    cr.arc(0.0, 0.0, 1.0, 0.0, 2.0 * pi);
    cr.restore();
}

/// https://github.com/pygobject/pycairo/blob/master/examples/pycairo_examples.ipynb
fn ellipseExample(cr: *cairo.Context) void {
    cr.setSourceRgba(1, 0, 0, 1);
    pathEllipse(cr, 128, 128, 256, 76.8, pi / 4.0);
    cr.fillPreserve();

    cr.setLineWidth(3.0);
    cr.setSourceRgba(0, 0, 0, 1);
    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("ellipse example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.fromSurface(&surface);
    defer cr.destroy();

    setBackground(&cr);
    ellipseExample(&cr);
    _ = surface.writeToPng("examples/generated/ellipse.png");
}
