const std = @import("std");
const builtin = @import("builtin");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

const BezierCubic = struct {
    x1: f64, // (x1, y1) is the first control point
    y1: f64,
    x2: f64, // (x2, y2) is the second control point
    y2: f64,
    x3: f64, // (x3, y3) is where the curve ends
    y3: f64,
};

fn drawCubicBezier(cr: *cairo.Context, x0: f64, y0: f64, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) void {
    // bezier curve
    cr.setSourceRgb(0.0, 0.0, 0.0);
    const bc = BezierCubic{ .x1 = x1, .y1 = y1, .x2 = x2, .y2 = y2, .x3 = x3, .y3 = y3 };
    cr.lineTo(x0, y0);
    cr.curveTo(bc.x1, bc.y1, bc.x2, bc.y2, bc.x3, bc.y3);
    cr.stroke();

    // red lines
    cr.setSourceRgba(1, 0, 0, 0.75);
    cr.moveTo(x0, y0);
    cr.lineTo(bc.x1, bc.y1);
    cr.moveTo(bc.x3, bc.y3);
    cr.lineTo(bc.x2, bc.y2);
    cr.stroke();

    // red dots
    const radius = 1.5;
    cr.arc(x0, y0, radius, 0, 2 * pi);
    cr.arc(x1, y1, radius, 0, 2 * pi);
    cr.fill();
    cr.arc(x2, y2, radius, 0, 2 * pi);
    cr.arc(x3, y3, radius, 0, 2 * pi);
    cr.fill();
}

/// Draw 9 cubic Bézier curves with helping lines that highlight each curve control points.
/// https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths#curve_commands
fn drawBezierCurves(cr: *cairo.Context) void {
    cr.scale(2.0, 2.0);
    cr.setLineWidth(1.0); // to counterbalance the scaling

    drawCubicBezier(cr, 10, 10, 20, 20, 40, 20, 50, 10);
    drawCubicBezier(cr, 70, 10, 70, 20, 110, 20, 110, 10);
    drawCubicBezier(cr, 130, 10, 120, 20, 180, 20, 170, 10);

    drawCubicBezier(cr, 10, 60, 20, 80, 40, 80, 50, 60);
    drawCubicBezier(cr, 70, 60, 70, 80, 110, 80, 110, 60);
    drawCubicBezier(cr, 130, 60, 120, 80, 180, 80, 170, 60);

    drawCubicBezier(cr, 10, 110, 20, 140, 40, 140, 50, 110);
    drawCubicBezier(cr, 70, 110, 70, 140, 110, 140, 110, 110);
    drawCubicBezier(cr, 130, 110, 120, 140, 180, 140, 170, 110);
}

pub fn main() !void {
    const width: u16 = 400;
    const height: u16 = 400;
    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    drawBezierCurves(&cr);
    _ = surface.writeToPng("examples/generated/bezier.png");
}
