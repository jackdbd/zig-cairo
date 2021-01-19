const std = @import("std");
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/curve_rectangle/
fn curveRectangle(cr: *cairo.Context, width: usize, height: usize) void {
    const x0: f64 = 25.6;
    const y0: f64 = 25.6;
    const rect_width: f64 = 204.8;
    const rect_height: f64 = 204.8;
    const radius: f64 = 102.4;
    const x1 = x0 + rect_width;
    const y1 = y0 + rect_height;

    if (rect_width / 2 < radius) {
        if (rect_height / 2 < radius) {
            cr.moveTo(x0, (y0 + y1) / 2);
            cr.curve_to(x0, y0, x0, y0, (x0 + x1) / 2, y0);
            cr.curveTo(x1, y0, x1, y0, x1, (y0 + y1) / 2);
            cr.curveTo(x1, y1, x1, y1, (x1 + x0) / 2, y1);
            cr.curveTo(x0, y1, x0, y1, x0, (y0 + y1) / 2);
        } else {
            cr.moveTo(x0, y0 + radius);
            cr.curveTo(x0, y0, x0, y0, (x0 + x1) / 2, y0);
            cr.curveTo(x1, y0, x1, y0, x1, y0 + radius);
            cr.lineTo(x1, y1 - radius);
            cr.curveTo(x1, y1, x1, y1, (x1 + x0) / 2, y1);
            cr.curveTo(x0, y1, x0, y1, x0, y1 - radius);
        }
    } else {
        if (rect_height / 2 < radius) {
            cr.moveTo(x0, (y0 + y1) / 2);
            cr.curveTo(x0, y0, x0, y0, x0 + radius, y0);
            cr.lineTo(x1 - radius, y0);
            cr.curveTo(x1, y0, x1, y0, x1, (y0 + y1) / 2);
            cr.curveTo(x1, y1, x1, y1, x1 - radius, y1);
            cr.lineTo(x0 + radius, y1);
            cr.curveTo(x0, y1, x0, y1, x0, (y0 + y1) / 2);
        } else {
            cr.moveTo(x0, y0 + radius);
            cr.curveTo(x0, y0, x0, y0, x0 + radius, y0);
            cr.lineTo(x1 - radius, y0);
            cr.curveTo(x1, y0, x1, y0, x1, y0 + radius);
            cr.lineTo(x1, y1 - radius);
            cr.curveTo(x1, y1, x1, y1, x1 - radius, y1);
            cr.lineTo(x0 + radius, y1);
            cr.curveTo(x0, y1, x0, y1, x0, y1 - radius);
        }
    }
    cr.closePath();

    cr.setSourceRgb(0.5, 0.5, 1);
    cr.fillPreserve();
    cr.setSourceRgba(0.5, 0, 0, 0.5);
    cr.setLineWidth(10.0);
    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("curve_rectangle example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.fromSurface(&surface);
    defer cr.destroy();

    setBackground(&cr);
    curveRectangle(&cr, width, height);
    _ = surface.writeToPng("examples/generated/curve_rectangle.png");
}
