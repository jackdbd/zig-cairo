const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");

/// d3 margin convention
/// https://bl.ocks.org/mbostock/3019563/0a647e163b8e86eb043621fe1208c81396dea407
/// https://observablehq.com/@d3/margin-convention?spm=a2c6h.14275010.0.0.2cf31e8bhYyt85
const MarginConvention = struct {
    margin: Margin,
    padding: Padding,
    outer_width: u16,
    outer_height: u16,
    inner_width: u16,
    inner_height: u16,
    width: u16,
    height: u16,
};

fn marginConvention(outer_width: u16, outer_height: u16, margin: Margin, padding: Padding) MarginConvention {
    const inner_width = outer_width - margin.left - margin.right;
    const inner_height = outer_height - margin.top - margin.bottom;
    const width = inner_width - padding.left - padding.right;
    const height = inner_height - padding.top - padding.bottom;

    return MarginConvention{
        .margin = margin,
        .padding = padding,
        .outer_width = outer_width,
        .outer_height = outer_height,
        .inner_width = inner_width,
        .inner_height = inner_height,
        .width = width,
        .height = height,
    };
}

fn drawLineChart(cr: *cairo.Context, comptime cfg: Config) !void {
    comptime {
        if (cfg.outer_width == 0) {
            @compileError("`outer_width` must be greater than 0");
        }
        if (cfg.outer_height == 0) {
            @compileError("`outer_height` must be greater than 0");
        }
    }
    const inner_width = cfg.outer_width - cfg.margin.left - cfg.margin.right;
    const inner_height = cfg.outer_height - cfg.margin.top - cfg.margin.bottom;
    const width = inner_width - cfg.padding.left - cfg.padding.right;
    const height = inner_height - cfg.padding.top - cfg.padding.bottom;

    // scale functions
    // axes

    cr.setSourceRgb(0.66, 0.66, 0.66); // dark gray #a9a9a9
    cr.paintWithAlpha(1.0);

    drawMarginFrame(cr, cfg.margin, inner_width, inner_height);

    var points = [_]Point{
        .{ .x = 0, .y = 85 },
        .{ .x = 1, .y = 75 },
        .{ .x = 2, .y = 10 },
        .{ .x = 5, .y = 75 },
        .{ .x = 10, .y = 85 },
        .{ .x = 15, .y = 190 },
        .{ .x = 16, .y = 150 },
        .{ .x = 19, .y = 190 },
        .{ .x = 20, .y = 125 },
    };
    const b = bounds(points[0..]);
    drawChart(cr, cfg, width, height, points[0..], b);
    try drawTicks(std.testing.allocator, cr, cfg, width, height, b);

    try drawArrows(cr, cfg);
}

/// Draw the margin frame
fn drawMarginFrame(cr: *cairo.Context, margin: Margin, width: u16, height: u16) void {
    const x0 = @intToFloat(f64, margin.left);
    const y0 = @intToFloat(f64, margin.top);
    cr.save();

    cr.setLineWidth(4.0);
    cr.setSourceRgb(0, 0, 1);
    cr.rectangle(x0, y0, @intToFloat(f64, width), @intToFloat(f64, height));
    cr.strokePreserve();
    cr.setSourceRgb(1, 1, 1);
    cr.fill();

    cr.restore();
}

fn drawTicks(allocator: *std.mem.Allocator, cr: *cairo.Context, comptime cfg: Config, comptime width: u16, comptime height: u16, b: Bounds) !void {
    cr.save();

    cr.setLineWidth(2.0);

    const x0 = @intToFloat(f64, cfg.margin.left + cfg.padding.left);
    const y0 = @intToFloat(f64, cfg.margin.top + cfg.padding.top);
    const w = @intToFloat(f64, width);
    const h = @intToFloat(f64, height);
    const margin_size = @intToFloat(f64, cfg.margin.left);

    // cr.moveTo(x0 + textOffset.x, y0 - textOffset.y);
    cr.selectFontFace("Sans", cairo.FontSlant.Normal, cairo.FontWeight.Normal);
    cr.setFontSize(12.0);

    const tick_size: f64 = 5.0;
    const num_ticks: f64 = 10;
    const text_offset = .{ .x = 4, .y = 6 };

    var i: usize = 0;
    while (i < num_ticks) : (i += 1) {
        const i_f64 = @intToFloat(f64, i);
        cr.setSourceRgb(1, 0, 0); // red
        const x = x0 + (i_f64 * w / num_ticks);
        cr.moveTo(x, y0 + h - tick_size);
        cr.lineTo(x, y0 + h + tick_size);
        cr.stroke();
        const x_tick = x * (b.x_max - b.x_min) / w;
        const x_label = try std.fmt.allocPrintZ(allocator, "{d:.1}", .{x_tick});
        cr.moveTo(x - text_offset.x, y0 + h - tick_size - text_offset.y);
        cr.showText(x_label.ptr);

        cr.setSourceRgb(0, 1, 0); // green
        const y = y0 + h - (i_f64 * h / num_ticks);
        cr.moveTo(x0 - tick_size, y);
        cr.lineTo(x0 + tick_size, y);
        cr.stroke();
        const y_tick = y * (b.y_max - b.y_min) / h;
        // const y_tick = i_f64;
        const y_label = try std.fmt.allocPrintZ(allocator, "{d:.2}", .{y_tick});
        cr.moveTo(x0 + tick_size + text_offset.x, y);
        cr.showText(y_label.ptr);
        // these ones are for testing
        cr.setSourceRgb(0, 0, 1); // blue
        cr.moveTo(x0 + tick_size + text_offset.x + 20, y);
        const y_test_label = try std.fmt.allocPrintZ(allocator, "{d:.2}", .{i_f64});
        cr.showText(y_test_label.ptr);
    }

    cr.restore();
}

/// Draw the margin+padding frame and the chart area
fn drawChart(cr: *cairo.Context, comptime cfg: Config, comptime width: u16, comptime height: u16, points: []Point, b: Bounds) void {
    comptime {
        if (width <= 0) {
            @compileError("`width` must be greater than 0");
        }
        if (height <= 0) {
            @compileError("`height` must be greater than 0");
        }
    }
    const x0 = @intToFloat(f64, cfg.margin.left + cfg.padding.left);
    const y0 = @intToFloat(f64, cfg.margin.top + cfg.padding.top);
    const w = @intToFloat(f64, width);
    const h = @intToFloat(f64, height);

    cr.save();

    cr.setLineWidth(2.0);

    // top line is dashed
    var dashes_arr = [_]f64{
        6.0, // ink
        3.0, // skip
    };
    const offset: f64 = 0.0;
    cr.setDash(dashes_arr[0..], offset);
    cr.setSourceRgb(0, 0, 0);
    const text_offset = .{ .x = 4, .y = 6 };
    cr.moveTo(x0 + text_offset.x, y0 - text_offset.y);
    cr.selectFontFace("Sans", cairo.FontSlant.Normal, cairo.FontWeight.Normal);
    cr.setFontSize(12.0);
    cr.showText("translate(margin.left, margin.top)");
    cr.moveTo(x0, y0);
    cr.relLineTo(w, 0);
    cr.stroke();
    // left line is also dashed
    cr.moveTo(x0, y0);
    cr.relLineTo(0, h);
    cr.stroke();
    // bottom line is solid
    cr.setDash(dashes_arr[0..0], offset);
    cr.setSourceRgb(1, 0, 0);
    cr.moveTo(x0, y0 + h);
    cr.relLineTo(w, 0);
    cr.stroke();
    // right line is also solid
    cr.setSourceRgb(0, 1, 0);
    cr.moveTo(x0 + w, y0 + h);
    cr.relLineTo(0, -h);
    cr.stroke();
    // chart area
    cr.setSourceRgb(0.93, 0.93, 0.93); // gray
    cr.rectangle(x0, y0, w, h);
    cr.fill();

    // line chart
    cr.setSourceRgb(1, 0.647, 0); // orange
    cr.setLineWidth(3.0);

    var i: usize = 0;
    while (i < points.len) : (i += 1) {
        const x = x0 + (points[i].x * w / b.x_max);
        const y = y0 + h - (points[i].y * h / b.y_max);
        // std.debug.print("[{},{}]\n", .{x, y});
        cr.lineTo(x, y);
        cr.moveTo(x, y);
    }
    cr.stroke();

    cr.restore();
}

const Bounds = struct {
    x_min: f64,
    y_min: f64,
    x_max: f64,
    y_max: f64,
};

fn bounds(points: []Point) Bounds {
    // std.log.debug("points {}", .{points});
    var x_max: f64 = 0;
    var y_max: f64 = 0;
    var x_min = std.math.inf(f64);
    var y_min = std.math.inf(f64);
    for (points) |p| {
        if (p.x > x_max) x_max = p.x;
        if (p.y > y_max) y_max = p.y;
        if (p.x < x_min) x_min = p.x;
        if (p.x < y_min) y_min = p.y;
    }
    return Bounds{ .x_min = x_min, .y_min = y_min, .x_max = x_max, .y_max = y_max };
}

const Point = struct {
    x: f64,
    y: f64,
};

fn drawStar(cr: *cairo.Context) void {
    const points = [_]Point{
        .{ .x = 0, .y = 85 },
        .{ .x = 75, .y = 75 },
        .{ .x = 100, .y = 10 },
        .{ .x = 125, .y = 75 },
        .{ .x = 200, .y = 85 },
        .{ .x = 150, .y = 125 },
        .{ .x = 160, .y = 190 },
        .{ .x = 100, .y = 150 },
        .{ .x = 40, .y = 190 },
        .{ .x = 50, .y = 125 },
        .{ .x = 0, .y = 85 },
    };

    cr.save();

    var i: usize = 0;
    while (i < points.len) : (i += 1) {
        cr.lineTo(points[i].x, points[i].y);
    }
    cr.closePath();
    cr.setSourceRgb(1, 0, 0); // red
    cr.strokePreserve();
    cr.setSourceRgb(1, 0.647, 0); // orange
    cr.fill();

    cr.restore();
}

fn drawArrow(cr: *cairo.Context, src: Point, dest: Point, orientation: Orientation) void {
    cr.save();
    cr.setSourceRgb(1, 0.647, 0); // orange

    cr.moveTo(src.x, src.y);

    const side = 16.0;
    const h = side * @sqrt(3.0) / 2.0;
    const half_side = side / 2.0;
    switch (orientation) {
        .top => {
            cr.lineTo(dest.x, dest.y + h);
            cr.stroke();
            cr.translate(dest.x, dest.y + h);
            cr.rotate(180.0 * pi / 180.0);
        },
        .right => {
            cr.lineTo(dest.x - h, dest.y);
            cr.stroke();
            cr.translate(dest.x - h, dest.y);
            cr.rotate(-90.0 * pi / 180.0);
        },
        .bottom => {
            cr.lineTo(dest.x, dest.y - h);
            cr.stroke();
            cr.translate(dest.x, dest.y - h);
            cr.rotate(0);
        },
        .left => {
            cr.lineTo(dest.x + h, dest.y);
            cr.stroke();
            cr.translate(dest.x + h, dest.y);
            cr.rotate(90.0 * pi / 180.0);
        },
        .bottom_right => {
            cr.lineTo(dest.x - half_side, dest.y - half_side);
            cr.stroke();

            // draw the arrow origin
            // cr.setSourceRgb(1, 0, 0);
            const radius = 5.0;
            cr.arc(src.x, src.y, radius, 0, 2 * pi);
            cr.fill();

            // cr.setSourceRgb(1, 0.647, 0); // orange
            cr.translate(dest.x - half_side, dest.y - half_side);
            cr.rotate(-45.0 * pi / 180.0);
        },
        else => @panic("TODO finish implementing for other orientations"),
    }
    cr.moveTo(0, h);
    cr.relLineTo(-half_side, -h);
    cr.relLineTo(side, 0);
    cr.closePath();
    cr.fill();

    cr.restore();
}

const ArrowT = struct {
    src: Point,
    dest: Point,
    orientation: Orientation,
};

fn arrow(src: Point, dest: Point) !ArrowT {
    std.log.debug("Arrow src {} => dest {}", .{ src, dest });
    var orientation: Orientation = undefined;
    if (dest.x == src.x) {
        if (dest.y == src.y) {
            return error.SrcAndDestAreTheSame;
        } else if (dest.y > src.y) {
            orientation = Orientation.bottom;
        } else if (dest.y < src.y) {
            orientation = Orientation.top;
        }
    } else if (dest.x > src.x) {
        if (dest.y == src.y) {
            orientation = Orientation.right;
        } else if (dest.y > src.y) {
            orientation = Orientation.bottom_right;
        } else {
            orientation = Orientation.top_right;
        }
    } else { // dest.x < src.x
        if (dest.y == src.y) {
            orientation = Orientation.left;
        } else if (dest.y > src.y) {
            orientation = Orientation.bottom_left;
        } else {
            orientation = Orientation.top_left;
        }
    }
    return ArrowT{ .src = src, .dest = dest, .orientation = orientation };
}

// TODO: move drawArrow method here?
const Arrow = struct {
    src: Point,
    dest: Point,
    orientation: Orientation,

    const Self = @This();

    fn new(src: Point, dest: Point) !Self {
        std.log.debug("Arrow src {} => dest {}", .{ src, dest });
        var orientation: Orientation = undefined;
        if (dest.x == src.x) {
            if (dest.y == src.y) {
                return error.SrcAndDestAreTheSame;
            } else if (dest.y > src.y) {
                orientation = Orientation.bottom;
            } else if (dest.y < src.y) {
                orientation = Orientation.top;
            }
        } else if (dest.x > src.x) {
            if (dest.y == src.y) {
                orientation = Orientation.right;
            } else if (dest.y > src.y) {
                orientation = Orientation.bottom_right;
            } else {
                orientation = Orientation.top_right;
            }
        } else { // dest.x < src.x
            if (dest.y == src.y) {
                orientation = Orientation.left;
            } else if (dest.y > src.y) {
                orientation = Orientation.bottom_left;
            } else {
                orientation = Orientation.top_left;
            }
        }
        return Self{ .src = src, .dest = dest, .orientation = orientation };
    }
};

fn drawArrows(cr: *cairo.Context, comptime cfg: Config) !void {
    const x0 = @intToFloat(f64, cfg.margin.left);
    const y0 = @intToFloat(f64, cfg.margin.top);

    cr.save();

    const textOffset = .{ .x = 4, .y = 6 };
    cr.moveTo(x0 + textOffset.x, y0 - textOffset.y);
    cr.selectFontFace("Sans", cairo.FontSlant.Normal, cairo.FontWeight.Normal);
    cr.setFontSize(12.0);
    cr.setSourceRgb(1, 0.647, 0); // orange
    cr.showText("origin");

    cr.setLineWidth(4.0);

    const half_outer_width = @intToFloat(f64, cfg.outer_width) / 2.0;
    const half_outer_height = @intToFloat(f64, cfg.outer_height) / 2.0;

    // arrow at the top (points downwards)
    const src_top = .{ .x = half_outer_width, .y = cfg.margin.top };
    const dest_top = .{ .x = half_outer_width, .y = cfg.margin.top + cfg.padding.top };
    drawArrow(cr, src_top, dest_top, Orientation.bottom);

    // arrow on the right (points leftwards)
    const src_right = .{ .x = cfg.outer_width - cfg.margin.right, .y = half_outer_height };
    const dest_right = .{ .x = cfg.outer_width - cfg.margin.right - cfg.padding.right, .y = half_outer_height };
    drawArrow(cr, src_right, dest_right, Orientation.left);

    // arrow at the bottom (points upwards)
    const src_bottom = .{ .x = half_outer_width, .y = cfg.outer_height - cfg.margin.bottom };
    const dest_bottom = .{ .x = half_outer_width, .y = cfg.outer_height - cfg.margin.bottom - cfg.padding.bottom };
    const arrow_top_object = try Arrow.new(src_bottom, dest_bottom);
    const arrow_top_functional = try arrow(src_bottom, dest_bottom);
    drawArrow(cr, src_bottom, dest_bottom, Orientation.top);

    // arrow on the left (points rightwards)
    const src_left = .{ .x = cfg.margin.left, .y = half_outer_height };
    const dest_left = .{ .x = cfg.margin.left + cfg.padding.left, .y = half_outer_height };
    drawArrow(cr, src_left, dest_left, Orientation.right);

    // origin to top-left corner of the chart area
    const src_top_left = .{ .x = cfg.margin.left, .y = cfg.margin.top };
    const dest_top_left = .{ .x = cfg.margin.left + cfg.padding.left, .y = cfg.margin.top + cfg.padding.top };
    drawArrow(cr, src_top_left, dest_top_left, Orientation.bottom_right);

    cr.restore();
}

const Orientation = enum {
    top,
    right,
    bottom,
    left,
    top_right,
    top_left,
    bottom_right,
    bottom_left,
};

const Margin = struct {
    top: u16,
    right: u16,
    bottom: u16,
    left: u16,
};

const Padding = struct {
    top: u16,
    right: u16,
    bottom: u16,
    left: u16,
};

const default_margin = Margin{ .top = 20, .right = 10, .bottom = 20, .left = 10 };
const default_padding = Padding{ .top = 60, .right = 60, .bottom = 60, .left = 60 };

const Config = struct {
    margin: Margin = default_margin,
    padding: Padding = default_padding,
    outer_width: u16 = 960,
    outer_height: u16 = 500,
};

pub fn main() !void {
    // const cfg = marginConvention(1280, 720);
    const cfg = Config{ .outer_width = 1280, .outer_height = 720 };

    var surface = try cairo.Surface.image(cfg.outer_width, cfg.outer_height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    try drawLineChart(&cr, cfg);
    _ = surface.writeToPng("examples/generated/line_chart.png");
}
