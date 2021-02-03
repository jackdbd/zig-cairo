const std = @import("std");
const builtin = @import("builtin");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

const scale_x = 80.0;
const scale_y = 120.0;
const offset_x = 50.0;
const offset_y = 150.0;
const gap = 20.0;
const xmax = 3.0 * pi;

fn drawAxes(cr: *cairo.Context) void {
    cr.setSourceRgb(0, 0, 0); // black
    cr.moveTo(offset_x, offset_y);
    cr.lineTo(offset_x + scale_x * xmax, offset_y);
    cr.stroke();
    cr.moveTo(offset_x, offset_y - scale_y);
    cr.lineTo(offset_x, offset_y + scale_y);
    cr.stroke();
}

const Color = struct {
    r: f64,
    g: f64,
    b: f64,
};

const Point = struct {
    x: f64,
    y: f64,
};

fn point(x: f64, offset: f64) Point {
    const y = std.math.cos(x + offset);
    return Point{
        .x = x * scale_x + offset_x,
        .y = -y * scale_y + offset_y,
    };
}

fn drawCosine(cr: *cairo.Context, color: coloror, offset: f64) void {
    cr.setSourceRgb(color.r, color.g, color.b);
    var x: f64 = 0;
    const p0 = point(x, offset);
    cr.moveTo(p0.x, p0.y);
    while (x < xmax) : (x += pi / gap) {
        const p1 = point(x, offset);
        cr.lineTo(p1.x, p1.y);
    }
    cr.stroke();
}

/// This program draws a graph of three phase electrical voltages.
/// Zig porting of this example in Perl.
/// https://www.lemoda.net/electricity/three-phase-graph/index.html
fn drawThreePhases(cr: *cairo.Context) void {
    cr.setLineWidth(5.0);
    drawAxes(cr);
    drawCosine(cr, .{ .r = 1, .g = 0, .b = 0 }, 0);
    drawCosine(cr, .{ .r = 0, .g = 1, .b = 0 }, 2.0 * pi / 3.0);
    drawCosine(cr, .{ .r = 0, .g = 0, .b = 1 }, 4.0 * pi / 3.0);
}

pub fn main() !void {
    const size_y: u16 = 300;
    const size_x = size_y * 3;
    var surface = try cairo.Surface.image(size_x, size_y);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    drawThreePhases(&cr);
    _ = surface.writeToPng("examples/generated/three_phases.png");
}
