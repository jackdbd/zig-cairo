//! Example code to show how to use pangocairo to render text projected on a path.
//! https://gitlab.gnome.org/GNOME/pango/-/blob/master/examples/cairotwisted.c
const std = @import("std");
const log = std.log;
const pi = std.math.pi;
const cos = std.math.cos;
const cairo = @import("cairo");
const pc = @import("pangocairo");

/// A fancy cairo_stroke that draws points and control points, and connects them
/// together.
fn _fancyCairoStroke(cr: *cairo.Context, should_preserve: bool) !void {
    cr.save();

    cr.setSourceRgb(1.0, 0.0, 0.0); // red
    const line_width = cr.getLineWidth();
    var path = try cr.copyPath();
    defer path.destroy();

    cr.newPath();
    cr.save();
    cr.setLineWidth(line_width / 3.0);

    var dash = [_]f64{ 10.0, 10.0 }; // ink, skip
    const offset = 0.0;
    cr.setDash(dash[0..], offset);

    var iter = path.iterator();
    while (iter.next()) |pdt| {
        switch (pdt) {
            cairo.PathDataType.MoveTo, cairo.PathDataType.LineTo => {
                cr.moveTo(iter.data[1].point.x, iter.data[1].point.y);
            },
            cairo.PathDataType.CurveTo => {
                cr.lineTo(iter.data[1].point.x, iter.data[1].point.y);
                cr.moveTo(iter.data[2].point.x, iter.data[2].point.y);
                cr.lineTo(iter.data[3].point.x, iter.data[3].point.y);
            },
            cairo.PathDataType.ClosePath => {},
        }
    }

    cr.stroke();
    cr.restore();

    cr.save();
    cr.setLineWidth(line_width * 4.0);
    cr.setLineCap(cairo.LineCap.Round);

    iter = path.iterator();
    while (iter.next()) |pdt| {
        switch (pdt) {
            cairo.PathDataType.MoveTo => {
                cr.moveTo(iter.data[1].point.x, iter.data[1].point.y);
            },
            cairo.PathDataType.LineTo => {
                cr.relLineTo(0.0, 0.0);
                cr.moveTo(iter.data[1].point.x, iter.data[1].point.y);
            },
            cairo.PathDataType.CurveTo => {
                cr.relLineTo(0.0, 0.0);
                cr.moveTo(iter.data[1].point.x, iter.data[1].point.y);
                cr.relLineTo(0.0, 0.0);
                cr.moveTo(iter.data[2].point.x, iter.data[2].point.y);
                cr.relLineTo(0.0, 0.0);
                cr.moveTo(iter.data[3].point.x, iter.data[3].point.y);
            },
            cairo.PathDataType.ClosePath => {
                cr.relLineTo(0.0, 0.0);
            },
        }
    }

    cr.relLineTo(0.0, 0.0);
    cr.stroke();
    cr.restore();

    iter = path.iterator();
    while (iter.next()) |pdt| {
        switch (pdt) {
            cairo.PathDataType.MoveTo => {
                cr.moveTo(iter.data[1].point.x, iter.data[1].point.y);
            },
            cairo.PathDataType.LineTo => {
                cr.lineTo(iter.data[1].point.x, iter.data[1].point.y);
            },
            cairo.PathDataType.CurveTo => {
                cr.curveTo(
                    iter.data[1].point.x,
                    iter.data[1].point.y,
                    iter.data[2].point.x,
                    iter.data[2].point.y,
                    iter.data[3].point.x,
                    iter.data[3].point.y,
                );
            },
            cairo.PathDataType.ClosePath => {
                cr.closePath();
            },
        }
    }
    cr.stroke();

    if (should_preserve) {
        cr.appendPath(path);
    }

    cr.restore();
}

fn fancyCairoStroke(cr: *cairo.Context) !void {
    try _fancyCairoStroke(cr, false);
}

fn fancyCairoStrokePreserve(cr: *cairo.Context) !void {
    try _fancyCairoStroke(cr, true);
}

// DONE
fn drawText(cr: *cairo.Context, x: f64, y: f64, font: []const u8, text: []const u8) !void {
    var font_options = try cairo.FontOptions.create();
    defer font_options.destroy();

    _ = try cairo.FontOptions.status(font_options.c_ptr);

    font_options.setHintStyle(cairo.HintStyle.None);
    font_options.setHintMetrics(cairo.HintMetrics.Off);

    cr.setFontOptions(font_options);

    var layout = try pc.Layout.create(cr);
    defer layout.destroy();

    var desc = try pc.FontDescription.fromString(font);
    defer desc.destroy();

    layout.setFontDescription(desc);
    layout.setText(text);

    var line = try layout.getLineReadonly(0);
    cr.moveTo(x, y);
    pc.linePath(cr, line);
}

const ParametrizedPath = struct {
    path: *cairo.Path,
    parametrization: []f64,
};

/// Euclidean distance between two points.
fn twoPointsDistance(a: *cairo.CUnionPathData, b: *cairo.CUnionPathData) f64 {
    const dx = b.point.x - a.point.x;
    const dy = b.point.y - a.point.y;
    return std.math.sqrt(dx * dx + dy * dy);
}

fn curveLength(
    x0: f64,
    y0: f64,
    x1: f64,
    y1: f64,
    x2: f64,
    y2: f64,
    x3: f64,
    y3: f64,
) !f64 {
    var c_ptr = try cairo.image_surface.create(cairo.image_surface.Format.A8, 0, 0);
    var surface = cairo.Surface{ .surface = c_ptr };
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    cr.moveTo(x0, y0);
    cr.curveTo(x1, y1, x2, y2, x3, y3);

    var length: f64 = 0.0;
    var current_point: cairo.CUnionPathData = undefined;
    var path = try cr.copyPathFlat();
    var iter = path.iterator();
    while (iter.next()) |pdt| {
        switch (pdt) {
            cairo.PathDataType.MoveTo => {
                current_point = iter.data[1];
            },
            cairo.PathDataType.LineTo => {
                length += twoPointsDistance(&current_point, &iter.data[1]);
                current_point = iter.data[1];
            },
            cairo.PathDataType.CurveTo, cairo.PathDataType.ClosePath => unreachable,
        }
    }
    return length;
}

/// Compute parametrization info. That is, for each part of the cairo path,
/// tag it with its length. The caller owns the returned slice.
fn parametrizePath(allocator: *std.mem.Allocator, path: *cairo.Path) ![]f64 {
    const parametrization = try allocator.alloc(f64, @intCast(usize, path.c_ptr.num_data));
    // log.debug("slice.len {} {}", .{slice.len, @typeInfo(@TypeOf(slice))});

    var last_move_to: cairo.CUnionPathData = undefined;
    var current_point: cairo.CUnionPathData = undefined;

    var iter = path.iterator();
    for (parametrization) |p, i| {
        // log.debug("param {}", .{i});
        const pdt = iter.next();
        // log.debug("PathDataType {}", .{pdt});
        if (pdt != null) {
            switch (pdt.?) {
                cairo.PathDataType.MoveTo => {
                    last_move_to = iter.data[1];
                    current_point = iter.data[1];
                },
                cairo.PathDataType.ClosePath => {
                    // Make it look like it's a line_to to last_move_to
                    @panic("TODO");
                    // data = (&last_move_to) - 1;
                    // G_GNUC_FALLTHROUGH;
                    // log.debug("last_move_to {} {}", .{&last_move_to, last_move_to});
                },
                cairo.PathDataType.LineTo => {
                    const d = twoPointsDistance(&current_point, &iter.data[1]);
                    parametrization[i] = d;
                    // log.debug("parametrization[{}] {}", .{i, parametrization[i]});
                    current_point = iter.data[1];
                },
                cairo.PathDataType.CurveTo => {
                    // naive curve-length, treating bezier as three line segments:
                    // parametrization[i] = two_points_distance (&current_point, &data[1])
                    //  + two_points_distance (&data[1], &data[2])
                    //  + two_points_distance (&data[2], &data[3]);
                    //
                    const curve_length = try curveLength(
                        current_point.point.x,
                        current_point.point.y,
                        iter.data[1].point.x,
                        iter.data[1].point.y,
                        iter.data[2].point.x,
                        iter.data[2].point.y,
                        iter.data[3].point.x,
                        iter.data[3].point.y,
                    );
                    log.debug("curve_length {}", .{curve_length});
                    current_point = iter.data[3];
                },
            }
        }
    }
    return parametrization;
}

// TODO: I don't understand what to do here... review original C code.
fn pointOnPath(param_path: *ParametrizedPath) void {
    var last_move_to: cairo.CUnionPathData = undefined;
    var current_point: cairo.CUnionPathData = undefined;

    var iter = param_path.path.iterator();
    while (iter.next()) |pdt| {
        // log.debug("pdt {}", .{pdt});
        switch (pdt) {
            cairo.PathDataType.MoveTo => {
                last_move_to = iter.data[1];
                current_point = iter.data[1];
            },
            cairo.PathDataType.LineTo => {
                current_point = iter.data[1];
            },
            cairo.PathDataType.CurveTo => {
                current_point = iter.data[3];
            },
            cairo.PathDataType.ClosePath => {},
        }
    }
}

/// Project the current path of cr onto the provided path.
fn mapPathOnto(allocator: *std.mem.Allocator, cr: *cairo.Context, path: *cairo.Path) !void {
    log.debug("TODO mapPathOnto", .{});
    var parametrization = try parametrizePath(allocator, path);
    defer allocator.free(parametrization);

    var param_path = ParametrizedPath{
        .path = path,
        .parametrization = parametrization,
    };
    // log.debug("path parametrized in {} (segments?)", .{param_path.parametrization.len});

    var current_path = try cr.copyPath();
    defer current_path.destroy();

    cr.newPath();
    log.debug("transform current_path {}", .{current_path});
    pointOnPath(&param_path);
    // transform_path (current_path, (transform_point_func_t) point_on_path, &param);
    cr.appendPath(current_path);
}

// DONE
fn drawTwisted(cr: *cairo.Context, x: f64, y: f64, font: []const u8, text: []const u8) !void {
    cr.save();

    // decrease tolerance a bit, since it's going to be magnified
    cr.setTolerance(0.01);

    // Using cairo_copy_path() here shows our deficiency in handling Bezier
    // curves, specially around sharper curves.
    // Using cairo_copy_path_flat() on the other hand, magnifies the flattening
    // error with large off-path values.  We decreased tolerance for that reason.
    // Increase tolerance to see that artifact.
    var path = try cr.copyPathFlat();
    // var path = try cr.copyPath();
    defer path.destroy();

    cr.newPath();

    var allocator = std.testing.allocator;
    try drawText(cr, x, y + 100.0, font, text); // TODO: remove 100.0 from y. It's just for now to see the text
    try mapPathOnto(allocator, cr, &path);

    cr.fillPreserve();

    cr.save();
    cr.setSourceRgb(0.1, 0.1, 0.1);
    cr.stroke();
    cr.restore();

    cr.restore();
}

fn drawDream(cr: *cairo.Context) !void {
    cr.moveTo(50, 650);
    cr.relLineTo(250, 50);
    cr.relCurveTo(250, 50, 600, -50, 600, -250);
    cr.relCurveTo(0, -400, -300, -100, -800, -300);
    cr.setLineWidth(1.5);
    cr.setSourceRgba(0.3, 0.3, 1.0, 0.3);
    try fancyCairoStrokePreserve(cr);
    try drawTwisted(cr, 0.0, 0.0, "Serif 72", "It was a dream... Oh Just a dream...");
}

fn drawWow(cr: *cairo.Context) !void {
    cr.moveTo(400, 780);
    cr.relCurveTo(50, -50, 150, -50, 200, 0);
    cr.scale(1.0, 2.0);
    cr.setLineWidth(2.0);
    cr.setSourceRgba(0.3, 1.0, 0.3, 1.0);
    try fancyCairoStrokePreserve(cr);
    try drawTwisted(cr, -20.0, -150.0, "Serif 60", "WOW!");
}

pub fn main() !void {
    var surface = try cairo.Surface.image(1000, 800);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    cr.setSourceRgb(1.0, 1.0, 1.0); // white
    cr.paint();

    try drawDream(&cr);
    try drawWow(&cr);
    _ = surface.writeToPng("examples/generated/pango_twisted.png");
}
