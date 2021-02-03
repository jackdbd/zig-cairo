const std = @import("std");
const builtin = @import("builtin");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// Finds the singular values of the non-translation part of matrix.
///
/// Let M be the cairo transformation matrix in question:
///
///      ⌈xx xy⌉
///  M = |yx yy|
///      ⌊x0 y0⌋
///
/// The non-translation part is:
///
///   A = ⌈xx xy⌉
///       ⌊yx yy⌋
///
/// The non-zero singular values of A are the square roots of the non-zero
/// eigenvalues of A⁺ A, where A⁺ is A-transpose.
///
///   A⁺ A = ⌈xx yx⌉⌈xx xy⌉ = ⌈xx²+yx²     xx*xy+yx*yy⌉
///          ⌊xy yy⌋⌊yx yy⌋   ⌊xx*xy+yx*yy     xy²+yy²⌋
///
/// Name those:
///
///   B = A⁺ A = ⌈a k⌉
///              ⌊k b⌋
///
/// The eigenvalues of B satisfy:
///
///   λ² - (a+b).λ + a.b - k² = 0
///
/// The eigenvalues are:
///                __________________
///       (a+b) ± √(a+b)² - 4(a.b-k²)
///   λ = ---------------------------
///                   2
/// that simplifies to:
///                  _______________
///   λ = (a+b)/2 ± √((a-b)/2)² + k²
///
/// And the Singular values are the root of λs.
fn getSingularValues(matrix: *cairo.Matrix, major: *f64, minor: *f64) void {
    const xx = matrix.c_ptr.xx;
    const xy = matrix.c_ptr.xy;
    const yx = matrix.c_ptr.yx;
    const yy = matrix.c_ptr.yy;

    const a = xx * xx + yx * yx;
    const b = xy * xy + yy * yy;
    const k = xx * xy + yx * yy;

    const f = (a + b) * 0.5;
    const g = (a - b) * 0.5;
    const delta = std.math.sqrt(g * g + k * k);

    major.* = std.math.sqrt(f + delta);
    minor.* = std.math.sqrt(f - delta);
}

/// Find the length of the major and minor axes of the pen for a cairo_t,
/// identified by the current transformation matrix and line width.
/// Returned values are in device units.
fn getPenAxes(allocator: *std.mem.Allocator, cr: *cairo.Context, major: *f64, minor: *f64) !void {
    const width = cr.getLineWidth();
    var matrix = try cairo.Matrix.init(allocator, 0, 0, 0, 0, 0, 0);
    defer matrix.destroy();
    cr.getMatrix(&matrix);
    getSingularValues(&matrix, major, minor);
    major.* = major.* * width;
    minor.* = minor.* * width;
}

/// Use Singular values of transformation matrix to find the length of the major
/// and minor axes of the scaled pen.
/// Ported in Zig from this example in C.
/// https://github.com/freedesktop/cairo/blob/master/doc/tutorial/src/singular.c
fn draw(allocator: *std.mem.Allocator, cr: *cairo.Context, width: f64, height: f64) !void {
    // not sure what this `b` is. Boundary? And why dividing by 16?
    const b = (width + height) / 16.0;
    var major_width: f64 = 0.0;
    var minor_width: f64 = 0.0;

    // the spline we want to stroke
    cr.moveTo(width - b, b);
    cr.curveTo(-width, b, 2.0 * width, height - b, b, height - b);

    // the effect can be seen better with round caps
    cr.setLineCap(cairo.LineCap.round);

    // set the skewed pen
    cr.rotate(0.7);
    cr.scale(0.5, 2.0);
    cr.rotate(-0.7);
    cr.setLineWidth(b);

    try getPenAxes(allocator, cr, &major_width, &minor_width);

    // stroke with "major" pen in translucent red
    cr.save();
    cr.identityMatrix();
    cr.setLineWidth(major_width);
    cr.setSourceRgba(1.0, 0.0, 0.0, 0.9);
    cr.strokePreserve();
    cr.restore();

    // stroke with skewed pen in translucent black
    cr.setSourceRgba(0.0, 0.0, 0.0, 0.9);
    cr.strokePreserve();

    // stroke with "minor" pen in translucent yellow
    cr.save();
    cr.identityMatrix();
    cr.setLineWidth(minor_width);
    cr.setSourceRgba(1.0, 1.0, 0.0, 0.9);
    cr.strokePreserve();
    cr.restore();

    // stroke with hairline in black
    cr.save();
    cr.identityMatrix();
    cr.setLineWidth(1);
    cr.setSourceRgb(0.0, 0.0, 0.0);
    cr.strokePreserve();
    cr.restore();

    cr.newPath();
}

pub fn main() !void {
    const width: u16 = 400;
    const height: u16 = 400;
    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    var allocator = std.testing.allocator;
    setBackground(&cr);
    try draw(allocator, &cr, width, height);
    _ = surface.writeToPng("examples/generated/singular.png");
}
