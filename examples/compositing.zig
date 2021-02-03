const std = @import("std");
const builtin = @import("builtin");
const pi = std.math.pi;
const cairo = @import("cairo");
const Content = cairo.Content;
const Operator = cairo.Operator;
const setBackground = @import("utils.zig").setBackground;

fn draw(cr: *cairo.Context, width: u16, height: u16, x: f64, y: f64, rw: f64, rh: f64, op: OpAndName) !void {
    var surface = try cr.getTarget();

    var red = try surface.createSimilar(Content.color_alpha, width, height);
    defer red.destroy();
    var blue = try surface.createSimilar(Content.color_alpha, width, height);
    defer blue.destroy();

    var red_cr = try cairo.Context.create(&red);
    defer red_cr.destroy();

    red_cr.setSourceRgba(0.7, 0, 0, 0.8);
    red_cr.rectangle(x, y, rw, rh);
    red_cr.fill();

    var blue_cr = try cairo.Context.create(&blue);
    defer blue_cr.destroy();

    blue_cr.setSourceRgba(0, 0, 0.9, 0.4);
    blue_cr.rectangle(x + 40.0, y + 30.0, rw, rh);
    blue_cr.fill();

    red_cr.setOperator(op.op);

    // use the `blue` cairo.Surface to create a cairo.Pattern, then set that
    // pattern as the source for the `red_cr` cairo.Context.
    red_cr.setSourceSurface(&blue, 0, 0);
    red_cr.paint();

    cr.setSourceSurface(&red, 0, 0);
    cr.paint();

    cr.moveTo(x, y);
    cr.setSourceRgb(0.0, 0.0, 0.0);
    cr.showText(op.name.ptr);
}

const OpAndName = struct {
    op: Operator,
    name: []const u8,
};

/// https://www.cairographics.org/operators/
fn drawAll(cr: *cairo.Context, width: u16, height: u16) !void {
    const operators = [_]OpAndName{
        .{ .op = Operator.add, .name = "add" },
        .{ .op = Operator.atop, .name = "atop" },
        .{ .op = Operator.clear, .name = "clear" },
        .{ .op = Operator.color_burn, .name = "color_burn" },
        .{ .op = Operator.color_dodge, .name = "color_dodge" },
        .{ .op = Operator.darken, .name = "darken" },
        .{ .op = Operator.dest, .name = "dest" },
        .{ .op = Operator.dest_atop, .name = "dest_atop" },
        .{ .op = Operator.dest_in, .name = "dest_in" },
        .{ .op = Operator.dest_out, .name = "dest_out" },
        .{ .op = Operator.dest_over, .name = "dest_over" },
        .{ .op = Operator.difference, .name = "difference" },
        .{ .op = Operator.exclusion, .name = "exclusion" },
        .{ .op = Operator.hard_light, .name = "hard_light" },
        .{ .op = Operator.hsl_color, .name = "hsl_color" },
        .{ .op = Operator.hsl_hue, .name = "hsl_hue" },
        .{ .op = Operator.hsl_luminosity, .name = "hsl_luminosity" },
        .{ .op = Operator.hsl_saturation, .name = "hsl_saturation" },
        .{ .op = Operator.in, .name = "in" },
        .{ .op = Operator.lighten, .name = "lighten" },
        .{ .op = Operator.multiply, .name = "multiply" },
        .{ .op = Operator.out, .name = "out" },
        .{ .op = Operator.over, .name = "over" },
        .{ .op = Operator.overlay, .name = "overlay" },
        .{ .op = Operator.saturate, .name = "saturate" },
        .{ .op = Operator.screen, .name = "screen" },
        .{ .op = Operator.soft_light, .name = "soft_light" },
        .{ .op = Operator.source, .name = "source" },
        .{ .op = Operator.xor, .name = "xor" },
    };
    const k: usize = 6; // figures per row
    const rw = 120.0; // rectangle width
    const rh = 90.0; // rectangle height
    const margin = 20.0;
    const padding = 60.0;
    for (operators) |op, i| {
        const row = @divTrunc(i, k);
        const col = @mod(i, k);
        const pad_x = padding * @intToFloat(f64, col);
        const pad_y = padding * @intToFloat(f64, row);
        const x = margin + rw * @intToFloat(f64, col) + pad_x;
        const y = margin + (rh * @intToFloat(f64, row)) + pad_y;
        try draw(cr, width, height, x, y, rw, rh, op);
    }
}

pub fn main() !void {
    const width: u16 = 1200;
    const height: u16 = 800;
    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    cr.selectFontFace("Sans", cairo.FontSlant.normal, cairo.FontWeight.normal);
    cr.setFontSize(18.0);

    setBackground(&cr);
    try drawAll(&cr, width, height);
    _ = surface.writeToPng("examples/generated/compositing.png");
}
