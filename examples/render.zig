const std = @import("std");
const cairo = @import("cairo");

/// Render a test image on a Cairo context.
pub fn testImage(cr: *cairo.Context, width: usize, height: usize) void {
    const w = @intToFloat(f64, width);
    const h = @intToFloat(f64, height);

    // white background
    cr.setSourceRgb(1.0, 1.0, 1.0);
    cr.paintWithAlpha(1.0);

    // green rectangle
    cr.rectangle(0, 0, w / 2, h / 2);
    cr.setSourceRgba(0, 1, 0, 0.75);
    cr.fill();

    // red rectangle
    cr.rectangle(w / 2, h / 2, w, h);
    cr.setSourceRgba(1, 0, 0, 0.75);
    cr.fill();

    // thick line
    cr.setSourceRgba(0, 0.68, 0.68, 1.0);
    cr.setLineWidth(10.0);
    cr.moveTo(0, 0);
    cr.lineTo(w / 2, h / 2);
    cr.stroke();

    // some text
    const zig_motto = "all your codebase are belong to us";
    cr.selectFontFace("Georgia", cairo.FontSlant.normal, cairo.FontWeight.bold);
    cr.setFontSize(24.0);
    var te = cr.textExtents(zig_motto);
    cr.moveTo(w / 2 - te.width / 2 - te.x_bearing, h / 2 - te.height / 2 - te.y_bearing);
    cr.setSourceRgb(0.0, 0.0, 1.0);
    cr.showText(zig_motto);
}

const Point = struct {
    x: f64,
    y: f64,
};

/// Render a line chart on a Cairo context.
pub fn lineChart(cr: *cairo.Context, width: usize, height: usize) void {
    const points = [_]Point{
        .{ .x = 0, .y = 10 },
        .{ .x = 1, .y = 15 },
        .{ .x = 2, .y = 14 },
        .{ .x = 3, .y = 18 },
        .{ .x = 4, .y = 25 },
    };
    const max_height: f64 = 25;

    const w = @intToFloat(f64, width);
    const h = @intToFloat(f64, height);
    const origin = .{ .x = 0, .y = h };
    const n = @intToFloat(f64, points.len);
    const max_width = n - 1;

    // white background
    cr.setSourceRgb(1, 1, 1);
    cr.paintWithAlpha(1.0);

    // semi-transparent blue line
    cr.setLineWidth(2.0);
    cr.setSourceRgba(0.0, 0.0, 1.0, 0.5);
    cr.moveTo(origin.x, origin.y);

    var i: usize = 0;
    while (i < n) : (i += 1) {
        const x = points[i].x * w / max_width;
        const y = h - (points[i].y * h / max_height);
        cr.lineTo(x, y);
        cr.moveTo(x, y);
    }
    cr.stroke();
}
